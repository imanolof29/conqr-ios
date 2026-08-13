//
//  TerritoryDTO.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import Foundation
import CoreLocation

/// Mirrors backend TerritoryResponseDto (nest/conqr) — `boundary` comes as
/// [lat, lng] pairs, already ordered for direct MapPolygon rendering.
struct TerritoryDTO: Decodable, Identifiable, Equatable {
    let h3Index: String
    let ownerId: String
    let conqueredAt: Date
    let coordinates: [CLLocationCoordinate2D]

    var id: String { h3Index }

    private enum CodingKeys: String, CodingKey {
        case h3Index, ownerId, conqueredAt, boundary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        h3Index = try container.decode(String.self, forKey: .h3Index)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        conqueredAt = try container.decode(Date.self, forKey: .conqueredAt)
        let pairs = try container.decode([[Double]].self, forKey: .boundary)
        coordinates = pairs.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
    }

    static func == (lhs: TerritoryDTO, rhs: TerritoryDTO) -> Bool {
        lhs.h3Index == rhs.h3Index && lhs.ownerId == rhs.ownerId
    }
}
