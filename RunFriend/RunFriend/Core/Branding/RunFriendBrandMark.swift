import SwiftUI

/// The "run Friends" brand mark shown in the corner of shared avatar
/// images. Composited on-device after generation (see
/// `BrandMarkCompositor`), not left to the AI model — same reasoning as
/// the stats card: an exact logo shouldn't be left to chance.
///
/// TODO: placeholder recreation (sunset arcs + rounded wordmark) of the
/// reference branding — swap for the real logo asset once final brand
/// files exist.
struct RunFriendBrandMark: View {
    var body: some View {
        VStack(spacing: 0) {
            sunset
            Text("run Friends")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var sunset: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [.yellow, .orange, .pink], startPoint: .top, endPoint: .bottom))
                .frame(width: 36, height: 36)
                .mask(alignment: .top) { Rectangle().frame(height: 20) }
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule()
                        .fill(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 40, height: 3)
                }
            }
        }
        .frame(width: 40, height: 26)
    }
}

#Preview {
    RunFriendBrandMark()
        .padding(24)
        .background(Color(red: 0.29, green: 0.22, blue: 0.65))
}
