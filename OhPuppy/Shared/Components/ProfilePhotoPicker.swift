import SwiftUI
import PhotosUI

struct ProfilePhotoView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedItem: PhotosPickerItem?
    let size: CGFloat
    let cornerRadius: CGFloat
    let fallbackIcon: String
    let gradient: LinearGradient

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                if let url = store.profilePhotoURL,
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(gradient)
                        .frame(width: size, height: size)
                        .overlay {
                            Image(systemName: fallbackIcon)
                                .font(.system(size: size * 0.4, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                }

                Image(systemName: "camera.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(OPTheme.primary, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .offset(x: 4, y: 4)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.saveProfilePhoto(data)
                }
            }
        }
    }
}
