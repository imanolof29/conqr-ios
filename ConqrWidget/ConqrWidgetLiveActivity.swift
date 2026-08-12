//
//  ConqrWidgetLiveActivity.swift
//  ConqrWidget
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

struct ConqrWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ConqrWidgetAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.8))
                .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.activityType.title, systemImage: context.attributes.activityType.icon)
                        .foregroundStyle(context.attributes.activityType.color)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.attributes.startDate...Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: FinishWorkoutIntent()) {
                        Label("Finalizar", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red)
                }
            } compactLeading: {
                Image(systemName: context.attributes.activityType.icon)
                    .foregroundStyle(context.attributes.activityType.color)
            } compactTrailing: {
                Text(timerInterval: context.attributes.startDate...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .frame(width: 44)
            } minimal: {
                Image(systemName: context.attributes.activityType.icon)
                    .foregroundStyle(context.attributes.activityType.color)
            }
            .keylineTint(context.attributes.activityType.color)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ConqrWidgetAttributes>

    var body: some View {
        HStack {
            Label(context.attributes.activityType.title, systemImage: context.attributes.activityType.icon)
                .font(.headline)
                .foregroundStyle(context.attributes.activityType.color)

            Spacer()

            Text(timerInterval: context.attributes.startDate...Date.distantFuture, countsDown: false)
                .font(.title2.monospacedDigit())

            Button(intent: FinishWorkoutIntent()) {
                Label("Finalizar", systemImage: "stop.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
    }
}

extension ConqrWidgetAttributes {
    fileprivate static var preview: ConqrWidgetAttributes {
        ConqrWidgetAttributes(activityType: .run, startDate: .now.addingTimeInterval(-125))
    }
}

extension ConqrWidgetAttributes.ContentState {
    fileprivate static var running: ConqrWidgetAttributes.ContentState {
        ConqrWidgetAttributes.ContentState()
    }
}

#Preview("Notification", as: .content, using: ConqrWidgetAttributes.preview) {
   ConqrWidgetLiveActivity()
} contentStates: {
    ConqrWidgetAttributes.ContentState.running
}
