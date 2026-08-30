import SwiftUI

struct StyleAndGenerateView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject var viewModel: StyleAndGenerateViewModel

    var body: some View {
        VStack(spacing: 20) {
            StatsCardView(activity: viewModel.activity)
                .scaleEffect(0.7)
                .frame(height: 340)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(GenerationStyleCatalog.all) { style in
                        StyleThumbnail(
                            style: style,
                            isSelected: style.id == viewModel.selectedStyle.id,
                            isLocked: !style.isFree && !coordinator.entitlement.hasGearPack
                        ) {
                            if !style.isFree && !coordinator.entitlement.hasGearPack {
                                coordinator.isPaywallPresented = true
                            } else {
                                viewModel.selectedStyle = style
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            Button {
                guard !coordinator.requiresPaywall() else { return }
                Task {
                    if let avatar = await viewModel.generate() {
                        coordinator.push(.result(avatar))
                    }
                }
            } label: {
                if viewModel.isGenerating {
                    ProgressView("Generating…")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Generate My Avatar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isGenerating)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }
        }
        .navigationTitle("Style")
    }
}

private struct StyleThumbnail: View {
    let style: GenerationStyle
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(width: 84, height: 84)
                    if isLocked {
                        Image(systemName: "lock.fill").foregroundStyle(.secondary)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 3)
                )
                Text(style.displayName)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StyleAndGenerateView(
            viewModel: StyleAndGenerateViewModel(
                activity: .mockRuns[0],
                selfieData: Data(),
                generationAPI: MockGenerationAPI()
            )
        )
    }
    .environmentObject(AppCoordinator())
}
