import Combine
import Foundation

@MainActor
final class ResultViewModel: ObservableObject {
    let avatar: GeneratedAvatar

    /// The avatar image with the brand mark composited in — this is what
    /// gets displayed, saved, and shared, never the raw model output.
    let displayImageData: Data

    init(avatar: GeneratedAvatar) {
        self.avatar = avatar
        self.displayImageData = BrandMarkCompositor.composite(avatarImageData: avatar.imageData) ?? avatar.imageData
    }
}
