import SwiftUI

struct StravaConnectView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject var viewModel: StravaConnectViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Connect your Strava account to pull in your latest runs.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // TODO: swap for the official "Connect with Strava" button asset
            // before shipping — Strava's brand guidelines require their
            // button art, not a custom one.
            Button {
                Task {
                    if await viewModel.connect() {
                        coordinator.push(.activityPicker)
                    }
                }
            } label: {
                if viewModel.isConnecting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Connect with Strava")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(viewModel.isConnecting)
            .padding(.horizontal, 32)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }
            Spacer()
        }
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StravaConnectView(viewModel: StravaConnectViewModel(stravaAPI: MockStravaAPI()))
    }
    .environmentObject(AppCoordinator())
}
