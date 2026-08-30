import Combine
import Foundation

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    private let purchaseAPI: PurchaseAPI

    init(purchaseAPI: PurchaseAPI) {
        self.purchaseAPI = purchaseAPI
    }

    func purchase() async -> Entitlement? {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            return try await purchaseAPI.purchaseGearPack()
        } catch {
            errorMessage = "Purchase failed. Please try again."
            return nil
        }
    }

    func restore() async -> Entitlement? {
        try? await purchaseAPI.restorePurchases()
    }
}
