//
//  PolylineDecoder.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import CoreLocation

/// Decodes a Google Encoded Polyline Algorithm Format string (precision 5), matching what
/// the tracking backend returns for `WorkoutDTO.polyline` / `FinishedWorkoutPayload.polyline`.
enum PolylineDecoder {
    static func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat = 0
        var lng = 0

        while index < encoded.endIndex {
            lat += decodeValue(from: encoded, index: &index)
            lng += decodeValue(from: encoded, index: &index)
            coordinates.append(CLLocationCoordinate2D(latitude: Double(lat) / 1e5, longitude: Double(lng) / 1e5))
        }

        return coordinates
    }

    private static func decodeValue(from string: String, index: inout String.Index) -> Int {
        var result = 0
        var shift = 0
        var byte: Int

        repeat {
            byte = Int(string[index].asciiValue ?? 0) - 63
            index = string.index(after: index)
            result |= (byte & 0x1f) << shift
            shift += 5
        } while byte >= 0x20

        return (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
    }
}
