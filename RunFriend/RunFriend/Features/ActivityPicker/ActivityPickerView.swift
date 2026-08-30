import SwiftUI

struct ActivityPickerView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject var viewModel: ActivityPickerViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading your runs…")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            } else {
                List(viewModel.activities) { activity in
                    Button {
                        coordinator.push(.photoUpload(activity))
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.name).font(.headline)
                            Text("\(activity.stats.formattedDistance) · \(activity.stats.formattedDuration) · \(activity.startDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Pick a Run")
        .task { await viewModel.loadActivities() }
    }
}

#Preview {
    NavigationStack {
        ActivityPickerView(viewModel: ActivityPickerViewModel(stravaAPI: MockStravaAPI()))
    }
    .environmentObject(AppCoordinator())
}
