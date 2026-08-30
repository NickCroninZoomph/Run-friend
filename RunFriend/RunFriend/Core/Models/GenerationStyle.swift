import Foundation

/// A selectable cartoon art style. `referenceImageName` names the fixed
/// style-reference image handed to Gemini as one of the composite inputs.
struct GenerationStyle: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String
    let referenceImageName: String
    let isFree: Bool
    let tier: GenerationTier
}

/// Which Gemini image model this style uses — controls per-image cost.
enum GenerationTier: String, Codable, Hashable {
    case flash // Gemini 3.1 Flash Image, ~$0.07-0.10/image
    case pro   // Gemini 3 Pro Image, ~$0.13/image
}
