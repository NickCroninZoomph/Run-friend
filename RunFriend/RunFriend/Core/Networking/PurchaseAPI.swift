import Foundation

/// Wraps a StoreKit 2 purchase/restore plus the backend's `verifyPurchase`
/// call that actually flips the entitlement in Firestore. The client's
/// StoreKit transaction is never itself trusted as proof of purchase.
protocol PurchaseAPI: AnyObject {
    func purchaseGearPack() async throws -> Entitlement
    func restorePurchases() async throws -> Entitlement
    func currentEntitlement() async throws -> Entitlement
}

final class MockPurchaseAPI: PurchaseAPI {
    private var entitlement: Entitlement = .mockFree

    func purchaseGearPack() async throws -> Entitlement {
        try await Task.sleep(for: .seconds(1))
        entitlement.hasGearPack = true
        return entitlement
    }

    func restorePurchases() async throws -> Entitlement {
        try await Task.sleep(for: .milliseconds(500))
        return entitlement
    }

    func currentEntitlement() async throws -> Entitlement {
        entitlement
    }
}
