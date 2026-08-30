import SwiftUI

/// Composites `RunFriendBrandMark` onto a generated avatar image before
/// it's shown, saved, or shared — deterministic, so the mark is always
/// crisp regardless of what the AI model produced.
@MainActor
enum BrandMarkCompositor {
    static func composite(avatarImageData: Data) -> Data? {
        guard let baseImage = UIImage(data: avatarImageData) else { return nil }

        let content = ZStack(alignment: .topTrailing) {
            Image(uiImage: baseImage)
                .resizable()
                .scaledToFit()
            RunFriendBrandMark()
                .padding(baseImage.size.width * 0.04)
        }
        .frame(width: baseImage.size.width, height: baseImage.size.height)

        let renderer = ImageRenderer(content: content)
        renderer.scale = baseImage.scale
        guard let composited = renderer.uiImage else { return nil }
        return composited.pngData()
    }
}
