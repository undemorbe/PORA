import AppIntents
import SwiftUI
import WidgetKit

#if canImport(ActivityKit)
import ActivityKit

// Интерактивная кнопка «Куплено» на самой Live Activity (iOS 17+). Завершает
// активность для данного товара прямо с экрана блокировки, без открытия
// приложения. Отметка товара в приложении подхватится при следующем открытии.
@available(iOS 17.0, *)
struct MarkBoughtIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Mark bought"

    @Parameter(title: "itemId")
    var itemId: String

    init() {}
    init(itemId: String) { self.itemId = itemId }

    func perform() async throws -> some IntentResult {
        for activity in Activity<PoraActivityAttributes>.activities
        where activity.attributes.itemId == itemId {
            await activity.end(dismissalPolicy: .immediate)
        }
        return .result()
    }
}

// Widget Extension target «PoraLiveActivityWidget». Точка входа — @main
// WidgetBundle ниже. PoraActivityAttributes.swift шарится с Runner (обе
// галочки Target Membership).

@main
@available(iOS 16.1, *)
struct PoraWidgetBundle: WidgetBundle {
    var body: some Widget {
        PoraLiveActivityWidget()
    }
}

@available(iOS 16.1, *)
struct PoraLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PoraActivityAttributes.self) { context in
            // Вид на экране блокировки / в баннере.
            LockScreenLiveActivityView(context: context)
                .padding()
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "cart.fill").foregroundColor(.orange)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.title)
                            .font(.headline).lineLimit(1)
                        if !context.attributes.subtitle.isEmpty {
                            Text(context.attributes.subtitle)
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "cart.fill").foregroundColor(.orange)
            } compactTrailing: {
                Text(context.state.bought ? "OK" : "!")
            } minimal: {
                Image(systemName: "cart.fill").foregroundColor(.orange)
            }
        }
    }
}

@available(iOS 16.1, *)
private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PoraActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cart.fill")
                .font(.title2).foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.title)
                    .font(.headline).foregroundColor(.white).lineLimit(1)
                if !context.attributes.subtitle.isEmpty {
                    Text(context.attributes.subtitle)
                        .font(.subheadline).foregroundColor(.white.opacity(0.8))
                }
            }
            Spacer()
            // Интерактивная кнопка «Куплено» (iOS 17+). Label локализован в Dart.
            if #available(iOS 17.0, *), !context.attributes.actionLabel.isEmpty {
                Button(intent: MarkBoughtIntent(itemId: context.attributes.itemId)) {
                    Text(context.attributes.actionLabel)
                        .font(.subheadline.weight(.semibold))
                }
                .tint(.orange)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
#endif
