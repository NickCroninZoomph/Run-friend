import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: PaywallViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("Gear Pack")
                .font(.largeTitle.bold())
            Text("Unlock 3-5 more avatar styles and keep generating beyond the free limit.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            // NOTE: price/limit copy is a placeholder pending the free-tier
            // model decision (lifetime cap vs. monthly refresh) flagged in
            // the README.
            Text("$0.99 · one-time")
                .font(.headline)

            Spacer()

            Button {
                Task {
                    if let entitlement = await viewModel.purchase() {
                        coordinator.entitlement = entitlement
                        dismiss()
                    }
                }
            } label: {
                if viewModel.isPurchasing {
                    ProgressView().frame(maxWidth: .infinity).padding()
                } else {
                    Text("Unlock Gear Pack").font(.headline).frame(maxWidth: .infinity).padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            Button("Restore Purchases") {
                Task {
                    if let entitlement = await viewModel.restore() {
                        coordinator.entitlement = entitlement
                    }
                }
            }
            .font(.footnote)
            .padding(.bottom, 32)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }
        }
    }
}

#Preview {
    PaywallView(viewModel: PaywallViewModel(purchaseAPI: MockPurchaseAPI()))
        .environmentObject(AppCoordinator())
}
