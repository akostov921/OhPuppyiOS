import SwiftUI
import PhotosUI

struct EditDogView: View {
    let dog: Dog
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var breed: String
    @State private var birthDate: Date
    @State private var weight: String
    @State private var sex: Dog.Sex
    @State private var neutered: Bool
    @State private var microchip: String
    @State private var bio: String
    @State private var showDeleteAlert = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: Image?

    init(dog: Dog) {
        self.dog = dog
        _name = State(initialValue: dog.name)
        _breed = State(initialValue: dog.breed)
        _birthDate = State(initialValue: dog.birthDate)
        _weight = State(initialValue: String(format: "%.1f", dog.weight))
        _sex = State(initialValue: dog.sex)
        _neutered = State(initialValue: dog.neutered)
        _microchip = State(initialValue: dog.microchip ?? "")
        _bio = State(initialValue: dog.bio ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Редактирай\nпрофила")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("Промени данните на \(dog.name).")
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
                                        .overlay(Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 3))
                                } else {
                                    DogAvatar(url: dog.avatarURL, size: 100, showRing: true)
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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("БИОГРАФИЯ")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Разкажи нещо за кучето си...", text: $bio, axis: .vertical)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(OPTheme.text)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Button {
                        saveChanges()
                    } label: {
                        Text("Запази промените")
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
                    .padding(.top, 10)

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Изтрий кучето")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(OPTheme.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(OPTheme.dangerSoft, in: Capsule())
                    }
                    .padding(.top, 4)
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text("РЕДАКЦИЯ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textTertiary)
                        .tracking(0.8)
                }
            }
            .alert("Изтриване на \(dog.name)?", isPresented: $showDeleteAlert) {
                Button("Отказ", role: .cancel) {}
                Button("Изтрий", role: .destructive) {
                    withAnimation(OPTheme.springAnimation) {
                        store.deleteDog(id: dog.id)
                    }
                    dismiss()
                }
            } message: {
                Text("Всички данни за \(dog.name) ще бъдат изтрити завинаги. Това действие е необратимо.")
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

    private func saveChanges() {
        var updated = dog
        updated.name = name
        updated.breed = breed.isEmpty ? "Смесена" : breed
        updated.birthDate = birthDate
        updated.weight = Double(weight) ?? dog.weight
        updated.sex = sex
        updated.neutered = neutered
        updated.microchip = microchip.isEmpty ? nil : microchip
        updated.bio = bio.isEmpty ? nil : bio

        if let data = photoData {
            if let oldURL = dog.avatarURL, oldURL.isFileURL {
                PhotoStorage.delete(url: oldURL)
            }
            updated.avatarURL = PhotoStorage.save(imageData: data, for: dog.id)
        }

        withAnimation(OPTheme.springAnimation) {
            store.updateDog(updated)
        }
        dismiss()
    }
}
