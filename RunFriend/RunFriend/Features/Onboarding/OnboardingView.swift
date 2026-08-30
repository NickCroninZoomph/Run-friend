import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 88))
                .foregroundStyle(.orange)
            Text("Run Friend")
                .font(.largeTitle.bold())
            Text("Turn your Strava runs into a shareable cartoon avatar with your real stats on the card.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Spacer()
            Button {
                coordinator.hasCompletedOnboarding = true
                coordinator.push(.stravaConnect)
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingView().environmentObject(AppCoordinator())
}
