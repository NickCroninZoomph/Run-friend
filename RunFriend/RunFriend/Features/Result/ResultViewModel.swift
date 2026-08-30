import Combine
import Foundation

@MainActor
final class ResultViewModel: ObservableObject {
    let avatar: GeneratedAvatar

    init(avatar: GeneratedAvatar) {
        self.avatar = avatar
    }
}
