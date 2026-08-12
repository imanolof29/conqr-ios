//
//  ConqrWidgetBundle.swift
//  ConqrWidget
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import WidgetKit
import SwiftUI

@main
struct ConqrWidgetBundle: WidgetBundle {
    var body: some Widget {
        ConqrWidget()
        ConqrWidgetLiveActivity()
    }
}
