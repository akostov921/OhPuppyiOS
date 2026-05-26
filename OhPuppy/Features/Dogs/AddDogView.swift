import SwiftUI
import PhotosUI

struct AddDogView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var weight = ""
    @State private var sex: Dog.Sex = .male
    @State private var neutered = false
    @State private var microchip = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: Image?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Запознай ни\nс кучето си")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("Основни данни - останалото можеш да добавиш по-късно.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }

                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                if let photoImage {
                                    photoImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 3)
                                        )
                                } else {
                                    Circle()
                                        .fill(OPTheme.surfaceSunken)
                                        .frame(width: 100, height: 100)
                                        .overlay {
                                            Image(systemName: "pawprint.fill")
                                                .font(.system(size: 36))
                                                .foregroundStyle(OPTheme.mint.opacity(0.6))
                                        }
                                        .overlay(
                                            Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 3)
                                        )
                                }

                                Circle()
                                    .fill(OPTheme.primaryGradient)
                                    .frame(width: 34, height: 34)
                                    .overlay {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white)
                                    }
                                    .overlay(Circle().stroke(OPTheme.bg, lineWidth: 3))
                            }
                        }
                        Spacer()
                    }

                    formField("Име", text: $name, placeholder: "Рекс")
                    formField("Порода", text: $breed, placeholder: "Лабрадор ретривър")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ДАТА НА РАЖДАНЕ")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    formField("Тегло (кг)", text: $weight, placeholder: "14.2", keyboard: .decimalPad)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ПОЛ")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        HStack(spacing: 10) {
                            ForEach(Dog.Sex.allCases, id: \.self) { s in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { sex = s }
                                } label: {
                                    Text(s.label)
                                        .font(.system(size: 15, weight: sex == s ? .bold : .medium))
                                        .foregroundStyle(sex == s ? .white : OPTheme.text)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            sex == s ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                            in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                                        )
                                }
                            }
                        }
                    }

                    Toggle(isOn: $neutered) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Кастриран").font(.system(size: 15, weight: .medium)).foregroundStyle(OPTheme.text)
                            Text("По избор").font(.system(size: 12, weight: .medium)).foregroundStyle(OPTheme.textSecondary)
                        }
                    }
                    .tint(OPTheme.mint)
                    .padding(14)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))

                    formField("Микрочип №", text: $microchip, placeholder: "900164001234567", keyboard: .numberPad)
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 100)
            }
            .background(OPTheme.bg)
            .safeAreaInset(edge: .bottom) {
                Button {
                    saveDog()
                } label: {
                    Text("Продължи")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            name.isEmpty ? AnyShapeStyle(OPTheme.textTertiary) : AnyShapeStyle(OPTheme.primaryGradient),
                            in: Capsule()
                        )
                        .shadow(color: name.isEmpty ? .clear : OPTheme.primary.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(name.isEmpty)
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 16)
                .background(.ultraThinMaterial)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text("НОВО КУЧЕ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textTertiary)
                        .tracking(0.8)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                        if let uiImage = UIImage(data: data) {
                            photoImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(OPTheme.text)
                .keyboardType(keyboard)
                .padding(14)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func saveDog() {
        let w = Double(weight) ?? 0
        let dogId = UUID().uuidString

        var avatarURL: URL?
        if let data = photoData {
            avatarURL = PhotoStorage.save(imageData: data, for: dogId)
        }

        let dog = Dog(
            id: dogId,
            name: name,
            breed: breed.isEmpty ? "Смесена" : breed,
            birthDate: birthDate,
            sex: sex,
            neutered: neutered,
            weight: w,
            microchip: microchip.isEmpty ? nil : microchip,
            avatarURL: avatarURL,
            ownerId: "1"
        )
        withAnimation(OPTheme.springAnimation) {
            store.addDog(dog)
        }
        dismiss()
    }
}
