//
//  Double+Distance.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import Foundation

extension Double {
    var formattedAsDistance: String {
        Measurement(value: self, unit: UnitLength.meters).formatted(
            .measurement(width: .abbreviated, usage: .road, numberFormatStyle: .number.precision(.fractionLength(0...2)))
        )
    }
}
