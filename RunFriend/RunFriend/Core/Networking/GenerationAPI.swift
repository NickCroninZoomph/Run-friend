import Foundation

/// Client-side face of the backend's `generateAvatar` function: uploads the
/// selfie, the on-device-rendered stats card, and the chosen style, and gets
/// back the composited avatar image. The ~5-15s latency is a real server
/// round trip (Gemini image generation), simulated here with `Task.sleep`.
protocol GenerationAPI: AnyObject {
    func generateAvatar(
        selfie: Data,
        statsCardImage: Data,
        style: GenerationStyle,
        activity: RunActivity
    ) async throws -> GeneratedAvatar
}

enum GenerationAPIError: Error {
    case entitlementExhausted
    case generationFailed(String)
}

final class MockGenerationAPI: GenerationAPI {
    func generateAvatar(
        selfie: Data,
        statsCardImage: Data,
        style: GenerationStyle,
        activity: RunActivity
    ) async throws -> GeneratedAvatar {
        try await Task.sleep(for: .seconds(3))
        return GeneratedAvatar(
            id: UUID().uuidString,
            imageData: selfie, // placeholder: echoes the selfie back until Gemini is wired up
            style: style,
            activity: activity,
            createdAt: Date()
        )
    }
}
