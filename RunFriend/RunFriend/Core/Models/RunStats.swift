import Foundation

/// Display-ready run metrics, derived from a `RunActivity`.
///
/// TODO(open question): units are hardcoded to imperial (miles/feet) below.
/// Should this follow the device locale (km/m) instead? Flagged in the README.
struct RunStats: Hashable, Codable {
    var distanceMeters: Double
    var durationSeconds: Int
    var elevationGainMeters: Double
    var averageHeartRate: Double?
    var calories: Double?

    private static let milesPerMeter = 0.000621371
    private static let feetPerMeter = 3.28084

    var distanceMiles: Double { distanceMeters * Self.milesPerMeter }

    var formattedDistance: String {
        String(format: "%.2f mi", distanceMiles)
    }

    var formattedDuration: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = durationSeconds % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%d:%02d", minutes, seconds)
    }

    var formattedPace: String {
        guard distanceMiles > 0 else { return "--:-- /mi" }
        let secondsPerMile = Double(durationSeconds) / distanceMiles
        let minutes = Int(secondsPerMile) / 60
        let seconds = Int(secondsPerMile) % 60
        return String(format: "%d:%02d /mi", minutes, seconds)
    }

    var formattedElevation: String {
        String(format: "%.0f ft", elevationGainMeters * Self.feetPerMeter)
    }

    var formattedCalories: String {
        guard let calories else { return "--" }
        return String(format: "%.0f cal", calories)
    }

    var formattedHeartRate: String {
        guard let averageHeartRate else { return "--" }
        return String(format: "%.0f bpm", averageHeartRate)
    }
}
