import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isStravaConnected = false

    private let stravaAPI: StravaAPI

    init(stravaAPI: StravaAPI) {
        self.stravaAPI = stravaAPI
    }

    func refreshConnectionStatus() async {
        isStravaConnected = await stravaAPI.isConnected()
    }

    func disconnectStrava() async {
        await stravaAPI.disconnect()
        isStravaConnected = false
    }
}
