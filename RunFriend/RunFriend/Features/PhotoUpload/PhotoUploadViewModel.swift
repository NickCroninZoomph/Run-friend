import Combine
import PhotosUI
import SwiftUI

@MainActor
final class PhotoUploadViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { await loadImage() } }
    }
    @Published var selfieData: Data?
    @Published var isLoading = false

    private func loadImage() async {
        guard let selectedItem else { return }
        isLoading = true
        defer { isLoading = false }
        selfieData = try? await selectedItem.loadTransferable(type: Data.self)
    }
}
