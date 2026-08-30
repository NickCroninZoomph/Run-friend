import UIKit

/// Shares an image to Instagram Stories via the documented URL-scheme +
/// pasteboard handoff. Needs `instagram-stories` under
/// `LSApplicationQueriesSchemes` in Info.plist (set via project.yml).
/// No Meta developer account is required for this flow.
enum InstagramStoryShare {
    private static let facebookAppID = "" // set only if we ever need attribution

    static var isAvailable: Bool {
        guard let url = URL(string: "instagram-stories://share") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    static func shareBackground(imageData: Data) {
        guard let url = URL(string: "instagram-stories://share") else { return }

        var pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData,
        ]
        if !facebookAppID.isEmpty {
            pasteboardItems["com.instagram.sharedSticker.appID"] = facebookAppID
        }

        UIPasteboard.general.setItems(
            [pasteboardItems],
            options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
        )
        UIApplication.shared.open(url)
    }
}
