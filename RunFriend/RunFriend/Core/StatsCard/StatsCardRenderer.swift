import SwiftUI

/// Rasterizes `StatsCardView` on-device so the exact pixels — with correct,
/// legible numbers — can be sent to Gemini as an object-reference image.
@MainActor
enum StatsCardRenderer {
    static func renderPNGData(for activity: RunActivity, scale: CGFloat = 3) -> Data? {
        let renderer = ImageRenderer(content: StatsCardView(activity: activity))
        renderer.scale = scale
        #if canImport(UIKit)
        guard let uiImage = renderer.uiImage else { return nil }
        return uiImage.pngData()
        #else
        return nil
        #endif
    }
}
