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

struct FinishedWorkoutPayload: Equatable {
    let workoutId: String
    let distanceMeters: Double
    let polyline: String?
}

protocol TrackingSocketServicing: AnyObject {
    var onPointAck: ((Double) -> Void)? { get set }
    func startWorkout() async throws -> String
    func sendPoint(workoutId: String, lat: Double, lng: Double)
    func finishWorkout(workoutId: String) async throws -> FinishedWorkoutPayload
    func disconnect()
}


final class TrackingSocketService: TrackingSocketServicing {
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let ackTimeout: Double

    var onPointAck: ((Double) -> Void)?

    init(
        baseURL: URL = APIEnvironment.baseURL,
        tokenStore: AuthTokenStoring = KeychainTokenStore(),
        ackTimeout: Double = 10
    ) {
        self.ackTimeout = ackTimeout

        var config: SocketIOClientConfiguration = [.log(false), .compress, .forceWebsockets(true)]
        if let token = tokenStore.accessToken {
            config.insert(.extraHeaders(["Authorization": "Bearer \(token)"]))
        }

        manager = SocketManager(socketURL: baseURL, config: config)
        socket = manager.socket(forNamespace: "/tracking")

        socket.on("workout:point:ack") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any],
                  let distanceMeters = dict["distanceMeters"] as? Double else { return }
            self?.onPointAck?(distanceMeters)
        }
    }

    func startWorkout() async throws -> String {
        try await connect()

        let result: Result<String, TrackingSocketError> = await withTimeout { [socket] resume in
            socket.once("workout:started") { data, _ in
                guard let dict = data.first as? [String: Any],
                      let workoutId = dict["workoutId"] as? String else { return }
                resume(workoutId)
            }
            socket.emit("workout:start")
        }
        return try result.get()
    }

    func sendPoint(workoutId: String, lat: Double, lng: Double) {
        guard socket.status == .connected else { return }
        socket.emit("workout:point", ["workoutId": workoutId, "lat": lat, "lng": lng])
    }

    func finishWorkout(workoutId: String) async throws -> FinishedWorkoutPayload {
        try await connect()

        let result: Result<FinishedWorkoutPayload, TrackingSocketError> = await withTimeout { [socket] resume in
            socket.once("workout:finished") { data, _ in
                guard let dict = data.first as? [String: Any],
                      let id = dict["workoutId"] as? String,
                      let distanceMeters = dict["distanceMeters"] as? Double else { return }
                resume(FinishedWorkoutPayload(
                    workoutId: id,
                    distanceMeters: distanceMeters,
                    polyline: dict["polyline"] as? String
                ))
            }
            socket.emit("workout:finish", ["workoutId": workoutId])
        }
        return try result.get()
    }

    func disconnect() {
        socket.disconnect()
    }

    // MARK: - Connection

    private func connect() async throws {
        guard socket.status != .connected else { return }

        let result: Result<Void, TrackingSocketError> = await withTimeout { [socket] resume in
            socket.once(clientEvent: .connect) { _, _ in resume(()) }
            socket.connect()
        }
        if case .failure = result {
            throw TrackingSocketError.connectionFailed
        }
    }

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
            DispatchQueue.main.asyncAfter(deadline: .now() + ackTimeout, execute: timeoutWorkItem)

            operation { value in
                guard !didFinish else { return }
                didFinish = true
                timeoutWorkItem.cancel()
                continuation.resume(returning: .success(value))
            }
        }
    }
}
