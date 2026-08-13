//
//  TrackingSocketService.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation
import SocketIO

enum TrackingSocketError: Error, LocalizedError, Equatable {
    case connectionFailed
    case invalidPayload
    case timedOut

    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Could not connect to the tracking server."
        case .invalidPayload:
            return "The server sent an unexpected response."
        case .timedOut:
            return "The tracking server did not respond in time."
        }
    }
}

/// Mirrors the `territory:conquered` payload emitted by TrackingGateway
/// when a location update crosses into a new, previously-unowned H3 cell.
struct TerritoryConqueredPayload: Equatable {
    let h3Index: String
    let previousOwnerId: String?
    let newOwnerId: String
}

/// Only handles the live GPS stream — starting/finishing a workout is done
/// over REST (see RemoteTrackingService); this socket exists purely for
/// pushing `location:update` events and receiving conquest notifications.
protocol TrackingSocketServicing: AnyObject {
    var onTerritoryConquered: ((TerritoryConqueredPayload) -> Void)? { get set }
    var onServerError: ((String) -> Void)? { get set }
    func connect() async throws
    func sendLocation(workoutId: String, sequence: Int, timestamp: Date, lat: Double, lng: Double, accuracy: Double?)
    func disconnect()
}


final class TrackingSocketService: TrackingSocketServicing {
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let connectTimeout: Double

    var onTerritoryConquered: ((TerritoryConqueredPayload) -> Void)?
    var onServerError: ((String) -> Void)?

    init(
        baseURL: URL = APIEnvironment.baseURL,
        tokenStore: AuthTokenStoring = KeychainTokenStore(),
        connectTimeout: Double = 10
    ) {
        self.connectTimeout = connectTimeout

        var config: SocketIOClientConfiguration = [.log(false), .compress, .forceWebsockets(true)]
        if let token = tokenStore.accessToken {
            config.insert(.extraHeaders(["Authorization": "Bearer \(token)"]))
        }

        manager = SocketManager(socketURL: baseURL, config: config)
        socket = manager.socket(forNamespace: "/tracking")

        socket.on("territory:conquered") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any],
                  let h3Index = dict["h3Index"] as? String,
                  let newOwnerId = dict["newOwnerId"] as? String else { return }
            let payload = TerritoryConqueredPayload(
                h3Index: h3Index,
                previousOwnerId: dict["previousOwnerId"] as? String,
                newOwnerId: newOwnerId
            )
            Task { @MainActor [weak self] in
                self?.onTerritoryConquered?(payload)
            }
        }

        socket.on("error") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any],
                  let message = dict["message"] as? String else { return }
            Task { @MainActor [weak self] in
                self?.onServerError?(message)
            }
        }
    }

    func connect() async throws {
        guard socket.status != .connected else { return }

        let result: Result<Void, TrackingSocketError> = await withTimeout { [socket] resume in
            socket.once(clientEvent: .connect) { _, _ in Task { @MainActor in resume(()) } }
            socket.connect()
        }
        if case .failure = result {
            throw TrackingSocketError.connectionFailed
        }
    }

    func sendLocation(workoutId: String, sequence: Int, timestamp: Date, lat: Double, lng: Double, accuracy: Double?) {
        guard socket.status == .connected else { return }
        var payload: [String: Any] = [
            "workoutId": workoutId,
            "sequence": sequence,
            "timestamp": Self.timestampFormatter.string(from: timestamp),
            "latitude": lat,
            "longitude": lng
        ]
        if let accuracy {
            payload["accuracy"] = accuracy
        }
        socket.emit("location:update", payload)
    }

    func disconnect() {
        socket.disconnect()
    }

    // Server validates with @IsISO8601() and checks the value falls within a
    // clock-drift tolerance window, so fractional seconds/UTC are required.
    private static let timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    // MARK: - Connection

    private func withTimeout<T>(
        _ operation: (@escaping (T) -> Void) -> Void
    ) async -> Result<T, TrackingSocketError> {
        await withCheckedContinuation { (continuation: CheckedContinuation<Result<T, TrackingSocketError>, Never>) in
            var didFinish = false

            let timeoutWorkItem = DispatchWorkItem {
                guard !didFinish else { return }
                didFinish = true
                continuation.resume(returning: .failure(.timedOut))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + connectTimeout, execute: timeoutWorkItem)

            operation { value in
                guard !didFinish else { return }
                didFinish = true
                timeoutWorkItem.cancel()
                continuation.resume(returning: .success(value))
            }
        }
    }
}
