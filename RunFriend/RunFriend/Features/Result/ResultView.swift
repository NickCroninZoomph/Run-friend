import Photos
import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject var viewModel: ResultViewModel
    @State private var isShareSheetPresented = false

    var body: some View {
        VStack(spacing: 20) {
            if let uiImage = UIImage(data: viewModel.displayImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                Button {
                    InstagramStoryShare.shareBackground(imageData: viewModel.displayImageData)
                } label: {
                    Label("Share to Instagram Story", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!InstagramStoryShare.isAvailable)

                Button {
                    saveToPhotos()
                } label: {
                    Label("Save to Photos", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)

                Button {
                    isShareSheetPresented = true
                } label: {
                    Label("More Options", systemImage: "ellipsis.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)

                // TODO(open question): does Regenerate burn another one of
                // the 3 free generations (another Gemini call, another
                // ~$0.07-0.15), or is it a free retry within the same
                // session? Currently just pops back — no new charge/credit
                // logic wired up. See README.
                Button("Regenerate") {
                    coordinator.path.removeLast()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .navigationTitle("Your Avatar")
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShareSheetPresented) {
            if let uiImage = UIImage(data: viewModel.displayImageData) {
                ActivityShareSheet(items: [uiImage])
            }
        }
    }

    private func saveToPhotos() {
        guard let uiImage = UIImage(data: viewModel.displayImageData) else { return }
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
        }
    }
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ResultView(
            viewModel: ResultViewModel(
                avatar: GeneratedAvatar(
                    id: "1",
                    imageData: Data(),
                    style: GenerationStyleCatalog.freeStyle,
                    activity: .mockRuns[0],
                    createdAt: Date()
                )
            )
        )
    }
    .environmentObject(AppCoordinator())
}
