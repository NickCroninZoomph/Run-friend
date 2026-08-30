import Foundation

/// A point on the route thumbnail, normalized to 0...1 in card space.
struct RoutePoint: Hashable, Codable {
    var x: Double
    var y: Double
}

struct RunActivity: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let startDate: Date
    let distanceMeters: Double
    let movingTimeSeconds: Int
    let elevationGainMeters: Double
    let averageHeartRate: Double?
    let calories: Double?

    // Card display fields.
    //
    // TODO(open question): `athleteName`/`athleteAvatarURL` need to come
    // from the Strava athlete profile — `stravaGetActivities` doesn't
    // return those yet. `locationName` maps to Strava's
    // location_city/location_state. `routePoints` stands in for decoding
    // Strava's encoded `map.summary_polyline` (Google's encoded polyline
    // algorithm) into normalized card-space points — or alternatively
    // rendering a real MapKit snapshot. See the README.
    let athleteName: String
    let athleteAvatarURL: URL?
    let locationName: String?
    let routePoints: [RoutePoint]

    // TODO(open question): "top 10% of runs this week" isn't a Strava API
    // field — it has to be computed (e.g. against the athlete's own recent
    // activity history, which we already fetch) or dropped. `nil` means no
    // achievement line is shown.
    let achievementText: String?

    var stats: RunStats {
        RunStats(
            distanceMeters: distanceMeters,
            durationSeconds: movingTimeSeconds,
            elevationGainMeters: elevationGainMeters,
            averageHeartRate: averageHeartRate,
            calories: calories
        )
    }
}

/// Stand-in data for `MockStravaAPI` until real Strava credentials are wired up.
extension RunActivity {
    static let mockRuns: [RunActivity] = [
        RunActivity(
            id: "1",
            name: "Morning Riverside Run",
            startDate: Date().addingTimeInterval(-86_400),
            distanceMeters: 8046.72, // 5 mi
            movingTimeSeconds: 2460, // 41:00
            elevationGainMeters: 45,
            averageHeartRate: 152,
            calories: 512,
            athleteName: "Run Friend",
            athleteAvatarURL: nil,
            locationName: "Miami, FL",
            routePoints: [
                RoutePoint(x: 0.5, y: 0.92), RoutePoint(x: 0.46, y: 0.7), RoutePoint(x: 0.58, y: 0.5),
                RoutePoint(x: 0.42, y: 0.3), RoutePoint(x: 0.5, y: 0.08),
            ],
            achievementText: "Nice work! You were in the top 10% of runs this week."
        ),
        RunActivity(
            id: "2",
            name: "Tempo Intervals",
            startDate: Date().addingTimeInterval(-3 * 86_400),
            distanceMeters: 6437.4, // 4 mi
            movingTimeSeconds: 1740,
            elevationGainMeters: 22,
            averageHeartRate: 168,
            calories: 430,
            athleteName: "Run Friend",
            athleteAvatarURL: nil,
            locationName: "Salt Lake City, UT",
            routePoints: [
                RoutePoint(x: 0.15, y: 0.85), RoutePoint(x: 0.4, y: 0.6), RoutePoint(x: 0.3, y: 0.35),
                RoutePoint(x: 0.6, y: 0.2), RoutePoint(x: 0.85, y: 0.15),
            ],
            achievementText: nil
        ),
        RunActivity(
            id: "3",
            name: "Long Sunday Run",
            startDate: Date().addingTimeInterval(-6 * 86_400),
            distanceMeters: 16093.4, // 10 mi
            movingTimeSeconds: 5400,
            elevationGainMeters: 120,
            averageHeartRate: 148,
            calories: 980,
            athleteName: "Run Friend",
            athleteAvatarURL: nil,
            locationName: "New York, NY",
            routePoints: [
                RoutePoint(x: 0.3, y: 0.85), RoutePoint(x: 0.25, y: 0.5), RoutePoint(x: 0.45, y: 0.15),
                RoutePoint(x: 0.7, y: 0.15), RoutePoint(x: 0.75, y: 0.5), RoutePoint(x: 0.55, y: 0.85),
                RoutePoint(x: 0.3, y: 0.85),
            ],
            achievementText: "Congrats! You just set your 2nd fastest time on this route."
        ),
    ]
}
