import Flutter
import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

/// Обрабатывает MethodChannel `pora/live_activity` из Dart
/// (`LiveActivityBridge`) и управляет жизненным циклом ActivityKit.
///
/// ПОДКЛЮЧЕНИЕ (вручную в Xcode — см. docs/NATIVE_FEATURES.md):
///   1. Файл входит в target Runner.
///   2. В AppDelegate после GeneratedPluginRegistrant:
///        if let controller = window?.rootViewController as? FlutterViewController {
///          LiveActivityManager.shared.register(with: controller.binaryMessenger)
///        }
///      (в этом проекте FlutterImplicitEngineDelegate — брать messenger у
///       активного FlutterViewController).
///   3. Info.plist: NSSupportsLiveActivities = YES.
@objc class LiveActivityManager: NSObject {
    @objc static let shared = LiveActivityManager()

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "pora/live_activity",
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 16.1, *) else {
            result(false)
            return
        }
        #if canImport(ActivityKit)
        switch call.method {
        case "start":
            guard let args = call.arguments as? [String: Any],
                  let itemId = args["itemId"] as? String,
                  let title = args["title"] as? String
            else {
                result(false)
                return
            }
            let subtitle = args["subtitle"] as? String ?? ""
            let actionLabel = args["actionLabel"] as? String ?? ""
            result(
                start(
                    itemId: itemId,
                    title: title,
                    subtitle: subtitle,
                    actionLabel: actionLabel
                )
            )
        case "end":
            guard let args = call.arguments as? [String: Any],
                  let itemId = args["itemId"] as? String
            else {
                result(nil)
                return
            }
            Task { await end(itemId: itemId) }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
        #else
        result(false)
        #endif
    }

    #if canImport(ActivityKit)
    @available(iOS 16.1, *)
    private func start(
        itemId: String,
        title: String,
        subtitle: String,
        actionLabel: String
    ) -> Bool {
        // Live Activities должны быть разрешены пользователем в настройках.
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        // Если для этого товара уже идёт активность — не плодим новую.
        let existing = Activity<PoraActivityAttributes>.activities.first {
            $0.attributes.itemId == itemId
        }
        if existing != nil { return true }

        let attributes = PoraActivityAttributes(
            itemId: itemId,
            title: title,
            subtitle: subtitle,
            actionLabel: actionLabel
        )
        let state = PoraActivityAttributes.ContentState(bought: false)
        do {
            _ = try Activity.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            return true
        } catch {
            NSLog("LiveActivity start error: \(error.localizedDescription)")
            return false
        }
    }

    @available(iOS 16.1, *)
    private func end(itemId: String) async {
        for activity in Activity<PoraActivityAttributes>.activities
        where activity.attributes.itemId == itemId {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
    #endif
}
