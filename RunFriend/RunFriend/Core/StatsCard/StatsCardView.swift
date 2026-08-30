import SwiftUI

/// The card the generated avatar "holds" — rendered natively so every
/// number on it is pixel-exact, then rasterized (see `StatsCardRenderer`)
/// and handed to Gemini as an object-reference image rather than letting
/// the model invent the digits itself.
struct StatsCardView: View {
    let activity: RunActivity

    private var stats: RunStats { activity.stats }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            Divider().overlay(Color.white.opacity(0.25))
            statsGrid
        }
        .padding(28)
        .frame(width: 360, height: 480)
        .background(
            LinearGradient(
                colors: [Color(red: 0.98, green: 0.31, blue: 0.15), Color(red: 0.95, green: 0.15, blue: 0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(activity.name.uppercased())
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
            Text(stats.formattedDistance)
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(activity.startDate.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            StatCell(label: "PACE", value: stats.formattedPace)
            StatCell(label: "TIME", value: stats.formattedDuration)
            StatCell(label: "ELEV GAIN", value: stats.formattedElevation)
            StatCell(label: "CALORIES", value: stats.formattedCalories)
            if activity.averageHeartRate != nil {
                StatCell(label: "AVG HR", value: stats.formattedHeartRate)
            }
        }
    }
}

private struct StatCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.65))
                .tracking(0.5)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    StatsCardView(activity: .mockRuns[0])
}
