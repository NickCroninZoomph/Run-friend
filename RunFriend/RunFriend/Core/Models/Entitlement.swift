import Foundation

/// Mirrors the server-side entitlement document (`users/{uid}.entitlement`
/// in Firestore, written only by Cloud Functions). The client caches this
/// for display but never treats it as authoritative for gating spend.
///
/// TODO(open question): `freeGenerationLimit`/`periodResetsAt` currently
/// model the spec's "3 lifetime generations" cap. If that gets flipped to a
/// soft monthly refresh (flagged in the README because $0.05-0.15/image
/// generation cost doesn't pencil out against a $1 lifetime unlock),
/// `periodResetsAt` becomes non-nil and `generateAvatar` resets
/// `generationsUsed` once it's in the past.
struct Entitlement: Codable, Equatable {
    var hasGearPack: Bool
    var generationsUsed: Int
    var freeGenerationLimit: Int
    var periodResetsAt: Date?

    var remainingFreeGenerations: Int {
        max(0, freeGenerationLimit - generationsUsed)
    }

    var canGenerate: Bool {
        hasGearPack || remainingFreeGenerations > 0
    }

    static let mockFree = Entitlement(hasGearPack: false, generationsUsed: 0, freeGenerationLimit: 3, periodResetsAt: nil)
}
