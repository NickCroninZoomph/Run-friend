import Combine
import Foundation

@MainActor
final class StyleAndGenerateViewModel: ObservableObject {
    @Published var selectedStyle: GenerationStyle
    @Published var isGenerating = false
    @Published var errorMessage: String?

    let activity: RunActivity
    let selfieData: Data
    private let generationAPI: GenerationAPI

    init(activity: RunActivity, selfieData: Data, generationAPI: GenerationAPI) {
        self.activity = activity
        self.selfieData = selfieData
        self.generationAPI = generationAPI
        self.selectedStyle = GenerationStyleCatalog.freeStyle
    }

    func generate() async -> GeneratedAvatar? {
        isGenerating = true
        defer { isGenerating = false }
        guard let statsCardData = StatsCardRenderer.renderPNGData(for: activity) else {
            errorMessage = "Couldn't render your stats card."
            return nil
        }
        do {
            return try await generationAPI.generateAvatar(
                selfie: selfieData,
                statsCardImage: statsCardData,
                style: selectedStyle,
                activity: activity
            )
        } catch {
            errorMessage = "Generation failed. Please try again."
            return nil
        }
    }
}
