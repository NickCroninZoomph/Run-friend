import Foundation

/// Placeholder style catalog. Real style-reference images (one fixed image
/// per style, fed to Gemini as a compositing input) still need to be
/// designed and added — see the README's open questions on whether those
/// ship bundled in the app or fetched from Cloud Storage/remote config.
enum GenerationStyleCatalog {
    static let all: [GenerationStyle] = [
        GenerationStyle(id: "comic-hero", displayName: "Comic Hero", referenceImageName: "style_comic_hero", isFree: true, tier: .flash),
        GenerationStyle(id: "pixel-runner", displayName: "Pixel Runner", referenceImageName: "style_pixel_runner", isFree: false, tier: .flash),
        GenerationStyle(id: "watercolor", displayName: "Watercolor", referenceImageName: "style_watercolor", isFree: false, tier: .flash),
        GenerationStyle(id: "anime-sprint", displayName: "Anime Sprint", referenceImageName: "style_anime_sprint", isFree: false, tier: .pro),
        GenerationStyle(id: "claymation", displayName: "Claymation", referenceImageName: "style_claymation", isFree: false, tier: .pro),
    ]

    static var freeStyle: GenerationStyle {
        all.first(where: \.isFree)!
    }
}
