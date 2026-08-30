import SwiftUI

struct RootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Group {
                if coordinator.hasCompletedOnboarding {
                    StravaConnectView(viewModel: StravaConnectViewModel(stravaAPI: coordinator.stravaAPI))
                } else {
                    OnboardingView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .sheet(isPresented: $coordinator.isPaywallPresented) {
            PaywallView(viewModel: PaywallViewModel(purchaseAPI: coordinator.purchaseAPI))
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .stravaConnect:
            StravaConnectView(viewModel: StravaConnectViewModel(stravaAPI: coordinator.stravaAPI))
        case .activityPicker:
            ActivityPickerView(viewModel: ActivityPickerViewModel(stravaAPI: coordinator.stravaAPI))
        case .photoUpload(let activity):
            PhotoUploadView(activity: activity)
        case .styleAndGenerate(let activity, let photo):
            StyleAndGenerateView(
                viewModel: StyleAndGenerateViewModel(activity: activity, selfieData: photo, generationAPI: MockGenerationAPI())
            )
        case .result(let avatar):
            ResultView(viewModel: ResultViewModel(avatar: avatar))
        case .paywall:
            PaywallView(viewModel: PaywallViewModel(purchaseAPI: coordinator.purchaseAPI))
        case .settings:
            SettingsView(viewModel: SettingsViewModel(stravaAPI: coordinator.stravaAPI))
        }
    }
}
