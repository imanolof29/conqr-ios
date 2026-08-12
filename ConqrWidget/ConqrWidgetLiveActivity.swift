//
//  ConqrWidgetLiveActivity.swift
//  ConqrWidget
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ConqrWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ConqrWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ConqrWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ConqrWidgetAttributes {
    fileprivate static var preview: ConqrWidgetAttributes {
        ConqrWidgetAttributes(name: "World")
    }
}

extension ConqrWidgetAttributes.ContentState {
    fileprivate static var smiley: ConqrWidgetAttributes.ContentState {
        ConqrWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ConqrWidgetAttributes.ContentState {
         ConqrWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ConqrWidgetAttributes.preview) {
   ConqrWidgetLiveActivity()
} contentStates: {
    ConqrWidgetAttributes.ContentState.smiley
    ConqrWidgetAttributes.ContentState.starEyes
}
