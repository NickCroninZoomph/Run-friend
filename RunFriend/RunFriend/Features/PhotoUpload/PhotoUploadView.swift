import PhotosUI
import SwiftUI

struct PhotoUploadView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = PhotoUploadViewModel()
    let activity: RunActivity

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            if let selfieData = viewModel.selfieData, let uiImage = UIImage(data: selfieData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 320)
                    .overlay {
                        Image(systemName: "person.crop.square")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                    }
            }

            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Text(viewModel.selfieData == nil ? "Choose a Selfie" : "Choose a Different Photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 32)

            Button {
                if let selfieData = viewModel.selfieData {
                    coordinator.push(.styleAndGenerate(activity, selfieData))
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.selfieData == nil)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            Spacer()
        }
        .navigationTitle("Your Photo")
    }
}

#Preview {
    NavigationStack {
        PhotoUploadView(activity: .mockRuns[0])
    }
    .environmentObject(AppCoordinator())
}
