import Foundation

struct GeneratedAvatar: Identifiable, Hashable {
    let id: String
    let imageData: Data
    let style: GenerationStyle
    let activity: RunActivity
    let createdAt: Date
}
