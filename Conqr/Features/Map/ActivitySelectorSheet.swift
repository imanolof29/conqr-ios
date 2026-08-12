import SwiftUI

struct ActivitySelectorSheet: View {
    @State private var selectedActivity: ActivityType?
    let onStart: (ActivityType) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Elige una actividad")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            GlassEffectContainer {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ActivityType.allCases) { activity in
                        SelectableGlassCard(
                            icon: activity.icon,
                            title: activity.title,
                            isSelected: selectedActivity == activity
                        ) {
                            selectedActivity = activity
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            PrimaryButton(title: "Iniciar", fullWidth: true) {
                if let selectedActivity {
                    onStart(selectedActivity)
                }
            }
            .disabled(selectedActivity == nil)
            .opacity(selectedActivity == nil ? 0.5 : 1)
        }
        .padding(20)
    }
}

#Preview {
    ActivitySelectorSheet { _ in }
}
