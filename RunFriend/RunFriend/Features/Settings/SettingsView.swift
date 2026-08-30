import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Strava") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(viewModel.isStravaConnected ? "Connected" : "Not Connected")
                        .foregroundStyle(.secondary)
                }
                if viewModel.isStravaConnected {
                    Button("Disconnect", role: .destructive) {
                        Task { await viewModel.disconnectStrava() }
                    }
                }
            }
            Section("Subscription") {
                HStack {
                    Text("Gear Pack")
                    Spacer()
                    Text(coordinator.entitlement.hasGearPack ? "Unlocked" : "Locked")
                        .foregroundStyle(.secondary)
                }
                if !coordinator.entitlement.hasGearPack {
                    Button("Unlock Gear Pack") {
                        coordinator.isPaywallPresented = true
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .task { await viewModel.refreshConnectionStatus() }
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(stravaAPI: MockStravaAPI()))
    }
    .environmentObject(AppCoordinator())
}
