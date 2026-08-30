import SwiftUI

private let stravaOrange = Color(red: 0.988, green: 0.298, blue: 0.008)

/// The card the generated avatar "holds" — rendered natively so every
/// number on it is pixel-exact, then rasterized (see `StatsCardRenderer`)
/// and handed to Gemini as an object-reference image rather than letting
/// the model invent the digits itself. Layout matches the reference
/// design: Strava wordmark, athlete row, route thumbnail, a 2x3 stat
/// grid, and an optional achievement line.
struct StatsCardView: View {
    let activity: RunActivity

    private var stats: RunStats { activity.stats }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("STRAVA")
                .font(.system(size: 20, weight: .heavy))
                .italic()
                .foregroundStyle(stravaOrange)

            athleteRow

            RouteThumbnail(points: activity.routePoints)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            statsGrid

            if let achievementText = activity.achievementText {
                Divider()
                HStack(alignment: .top, spacing: 8) {
                    Text("🏆")
                    Text(achievementText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.black.opacity(0.75))
                }
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }

    private var athleteRow: some View {
        HStack(spacing: 10) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.athleteName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.black.opacity(0.55))
            }
        }
    }

    private var avatar: some View {
        AsyncImage(url: activity.athleteAvatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.black.opacity(0.25))
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }

    private var subtitle: String {
        let dateText = activity.startDate.formatted(date: .abbreviated, time: .shortened)
        guard let locationName = activity.locationName else { return dateText }
        return "\(dateText) · \(locationName)"
    }

    private var statsGrid: some View {
        VStack(spacing: 12) {
            statRow(("Distance", stats.formattedDistance), ("Pace", stats.formattedPace))
            Divider()
            statRow(("Time", stats.formattedDuration), ("Elev Gain", stats.formattedElevation))
            Divider()
            statRow(("Calories", stats.formattedCalories), ("Avg HR", stats.formattedHeartRate))
        }
    }

    private func statRow(_ left: (String, String), _ right: (String, String)) -> some View {
        HStack {
            StatCell(label: left.0, value: left.1)
            Spacer()
            StatCell(label: right.0, value: right.1)
        }
    }
}

private struct StatCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.black.opacity(0.5))
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Stand-in for a real map snapshot: draws the run's route as a line over a
/// flat "map-like" background.
///
/// TODO(open question): swap for a real MapKit snapshot once Strava's
/// encoded `map.summary_polyline` is decoded into actual coordinates,
/// server- or client-side — see README.
private struct RouteThumbnail: View {
    let points: [RoutePoint]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.93, green: 0.92, blue: 0.88)
                if points.count > 1 {
                    Path { path in
                        let scaled = points.map {
                            CGPoint(x: $0.x * proxy.size.width, y: $0.y * proxy.size.height)
                        }
                        path.move(to: scaled[0])
                        for point in scaled.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(stravaOrange, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        StatsCardView(activity: .mockRuns[0])
        StatsCardView(activity: .mockRuns[1])
    }
    .padding()
    .background(Color(red: 0.29, green: 0.22, blue: 0.65))
}
