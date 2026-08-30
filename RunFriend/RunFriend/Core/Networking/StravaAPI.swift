import Foundation

/// Client-side face of the Strava integration. `connect()` is expected to
/// drive an `ASWebAuthenticationSession` through Strava's OAuth page, which
/// redirects to the backend's `stravaOAuthCallback` function; that function
/// stores the token and redirects back into the app via the `runfriend://`
/// URL scheme. `recentRuns` calls the backend's `stravaGetActivities`
/// function (never talks to Strava directly, so the client never sees the
/// access token).
protocol StravaAPI: AnyObject {
    func isConnected() async -> Bool
    func connect() async throws
    func disconnect() async
    func recentRuns(limit: Int) async throws -> [RunActivity]
}

enum StravaAPIError: Error {
    case notConnected
    case oauthCancelled
    case network(String)
}

final class MockStravaAPI: StravaAPI {
    private var connected = false

    func isConnected() async -> Bool {
        connected
    }

    func connect() async throws {
        try await Task.sleep(for: .seconds(1))
        connected = true
    }

    func disconnect() async {
        connected = false
    }

    func recentRuns(limit: Int) async throws -> [RunActivity] {
        try await Task.sleep(for: .seconds(1))
        return Array(RunActivity.mockRuns.prefix(limit))
    }
}
