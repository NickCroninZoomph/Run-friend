import Combine
import Foundation

@MainActor
final class StravaConnectViewModel: ObservableObject {
    @Published var isConnecting = false
    @Published var errorMessage: String?

    private let stravaAPI: StravaAPI

    init(stravaAPI: StravaAPI) {
        self.stravaAPI = stravaAPI
    }

    func connect() async -> Bool {
        isConnecting = true
        defer { isConnecting = false }
        do {
            try await stravaAPI.connect()
            return true
        } catch {
            errorMessage = "Couldn't connect to Strava. Please try again."
            return false
        }
    }
}
