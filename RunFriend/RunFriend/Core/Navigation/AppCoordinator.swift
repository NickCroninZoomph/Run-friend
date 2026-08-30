import Combine
import SwiftUI

/// Owns app-wide navigation state plus the handful of services/state that
/// need to be shared across features (Strava connection status, purchase
/// entitlement). Everything else is owned locally by each feature's
/// ViewModel.
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var hasCompletedOnboarding = false
    @Published var isPaywallPresented = false
    @Published var entitlement: Entitlement = .mockFree

    // Swap these for live implementations once Firebase is wired in (see README).
    let stravaAPI: StravaAPI = MockStravaAPI()
    let purchaseAPI: PurchaseAPI = MockPurchaseAPI()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    /// Presents the paywall and returns `true` if the user cannot currently
    /// generate (no remaining free generations and no Gear Pack).
    @discardableResult
    func requiresPaywall() -> Bool {
        guard !entitlement.canGenerate else { return false }
        isPaywallPresented = true
        return true
    }

    func refreshEntitlement() async {
        if let latest = try? await purchaseAPI.currentEntitlement() {
            entitlement = latest
        }
    }
}
