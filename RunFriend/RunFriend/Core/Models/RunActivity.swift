import Foundation

struct RunActivity: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let startDate: Date
    let distanceMeters: Double
    let movingTimeSeconds: Int
    let elevationGainMeters: Double
    let averageHeartRate: Double?
    let calories: Double?

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
            calories: 512
        ),
        RunActivity(
            id: "2",
            name: "Tempo Intervals",
            startDate: Date().addingTimeInterval(-3 * 86_400),
            distanceMeters: 6437.4, // 4 mi
            movingTimeSeconds: 1740,
            elevationGainMeters: 22,
            averageHeartRate: 168,
            calories: 430
        ),
        RunActivity(
            id: "3",
            name: "Long Sunday Run",
            startDate: Date().addingTimeInterval(-6 * 86_400),
            distanceMeters: 16093.4, // 10 mi
            movingTimeSeconds: 5400,
            elevationGainMeters: 120,
            averageHeartRate: 148,
            calories: 980
        ),
    ]
}
