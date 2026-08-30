import Combine
import Foundation

@MainActor
final class ActivityPickerViewModel: ObservableObject {
    @Published var activities: [RunActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let stravaAPI: StravaAPI

    init(stravaAPI: StravaAPI) {
        self.stravaAPI = stravaAPI
    }

    func loadActivities() async {
        isLoading = true
        defer { isLoading = false }
        do {
            activities = try await stravaAPI.recentRuns(limit: 10)
        } catch {
            errorMessage = "Couldn't load your recent runs."
        }
    }
}
