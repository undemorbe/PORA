import Foundation

#if canImport(ActivityKit)
import ActivityKit

// Общие атрибуты Live Activity. ДОЛЖНЫ быть в target membership И у Runner,
// И у widget-extension (галочки Target Membership в инспекторе файла Xcode),
// иначе типы не совпадут между приложением и виджетом.
//
// ВАЖНО: этот файл компилируется только при наличии ActivityKit (iOS 16.1+).
@available(iOS 16.1, *)
struct PoraActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Динамическая часть — можно обновлять, пока активность живёт.
        var bought: Bool
    }

    // Статическая часть — задаётся при старте и не меняется.
    // title/subtitle/actionLabel приходят УЖЕ локализованными из Dart
    // (Flutter l10n) — натив ничего не хардкодит и не переводит.
    var itemId: String
    var title: String
    var subtitle: String
    var actionLabel: String
}
#endif
