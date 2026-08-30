import Foundation

/// Caches the last-known entitlement locally so the UI has something to
/// show before the first Firestore/Functions round trip completes. The
/// server (`verifyPurchase` + Firestore) is always the source of truth —
/// never trust this cache to gate a purchase decision.
enum EntitlementStore {
    private static let key = "com.runfriend.cachedEntitlement"

    static func load() -> Entitlement? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Entitlement.self, from: data)
    }

    static func save(_ entitlement: Entitlement) {
        guard let data = try? JSONEncoder().encode(entitlement) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
