import SwiftUI

// MARK: - Add Vet Service Sheet

struct AddVetServiceSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var price = ""
    @State private var duration = "30 мин"
    @State private var category: VetServiceCategory = .exam
    private let durations = ["15 мин", "20 мин", "30 мин", "45 мин", "1 ч", "2 ч"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    dashField("Услуга", text: $name, placeholder: "Първичен преглед", icon: "stethoscope")
                    dashField("Цена (лв)", text: $price, placeholder: "50", icon: "banknote.fill")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ПРОДЪЛЖИТЕЛНОСТ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        FlowLayout(spacing: 8) {
                            ForEach(durations, id: \.self) { d in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { duration = d }
                                } label: {
                                    Text(d)
                                        .font(.system(size: 13, weight: duration == d ? .bold : .medium))
                                        .foregroundStyle(duration == d ? .white : OPTheme.text)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(duration == d ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: Capsule())
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("КАТЕГОРИЯ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        FlowLayout(spacing: 8) {
                            ForEach(VetServiceCategory.allCases, id: \.self) { cat in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { category = cat }
                                } label: {
                                    Label(cat.label, systemImage: cat.icon)
                                        .font(.system(size: 13, weight: category == cat ? .bold : .medium))
                                        .foregroundStyle(category == cat ? .white : OPTheme.text)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(category == cat ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: Capsule())
                                }
                            }
                        }
                    }

                    Button {
                        let service = VetService(id: store.newId(), name: name, price: Double(price) ?? 0, duration: duration, category: category)
                        store.addVetService(service)
                        dismiss()
                    } label: {
                        Text("Добави услуга")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                    .opacity(name.isEmpty || price.isEmpty ? 0.5 : 1)
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Нова услуга")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Затвори") { dismiss() } } }
        }
    }
}

// MARK: - Add Brand Product Sheet

struct AddBrandProductSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var price = ""
    @State private var category = "Храна"
    @State private var productDescription = ""
    private let categories = ["Храна", "Играчки", "Грижа", "Здраве", "Аксесоари", "Дрехи", "Легла"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(OPTheme.surfaceSunken)
                        .frame(height: 120)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 28))
                                    .foregroundStyle(OPTheme.accent.opacity(0.5))
                                Text("Добави снимка на продукта")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                        }

                    dashField("Продукт", text: $name, placeholder: "Premium Храна 12кг", icon: "shippingbox.fill")
                    dashField("Цена (лв)", text: $price, placeholder: "89.90", icon: "banknote.fill")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ОПИСАНИЕ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Опиши продукта...", text: $productDescription, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(3...5)
                            .padding(12)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("КАТЕГОРИЯ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        FlowLayout(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { category = cat }
                                } label: {
                                    Text(cat)
                                        .font(.system(size: 13, weight: category == cat ? .bold : .medium))
                                        .foregroundStyle(category == cat ? .white : OPTheme.text)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(category == cat ? AnyShapeStyle(OPTheme.accentGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: Capsule())
                                }
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(OPTheme.warning)
                        Text("Продуктът ще бъде прегледан от нашия екип преди публикуване.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .background(OPTheme.warningSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button {
                        let product = BrandProduct(id: store.newId(), name: name, price: Double(price) ?? 0, category: category, status: .pending, submittedAt: Date())
                        store.addBrandProduct(product)
                        dismiss()
                    } label: {
                        Text("Изпрати за одобрение")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(OPTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                    .opacity(name.isEmpty || price.isEmpty ? 0.5 : 1)
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Нов продукт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Затвори") { dismiss() } } }
        }
    }
}

// MARK: - Add Shelter Animal Sheet

struct AddShelterAnimalSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var breed = ""
    @State private var age = ""
    @State private var sex: Dog.Sex = .male
    @State private var description = ""
    @State private var selectedPhotoIndex = 0
    private let photoOptions = [
        "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&h=400&q=85",
        "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?auto=format&fit=crop&w=400&h=400&q=85",
        "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=400&h=400&q=85",
        "https://images.unsplash.com/photo-1534361960057-19889db9621e?auto=format&fit=crop&w=400&h=400&q=85",
        "https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?auto=format&fit=crop&w=400&h=400&q=85",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("СНИМКА")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<photoOptions.count, id: \.self) { i in
                                    Button {
                                        withAnimation(OPTheme.quickSpring) { selectedPhotoIndex = i }
                                    } label: {
                                        AsyncImage(url: URL(string: photoOptions[i])) { phase in
                                            if let image = phase.image {
                                                image.resizable().scaledToFill()
                                            } else {
                                                Rectangle().fill(OPTheme.surfaceSunken)
                                            }
                                        }
                                        .frame(width: 72, height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(selectedPhotoIndex == i ? OPTheme.rose : .clear, lineWidth: 3)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    dashField("Име", text: $name, placeholder: "Шаро", icon: "pawprint.fill")
                    dashField("Порода", text: $breed, placeholder: "Микс", icon: "dog.fill")
                    dashField("Възраст", text: $age, placeholder: "2 години", icon: "calendar")

                    HStack(spacing: 10) {
                        ForEach(Dog.Sex.allCases, id: \.self) { s in
                            Button {
                                withAnimation(OPTheme.quickSpring) { sex = s }
                            } label: {
                                Text(s.label)
                                    .font(.system(size: 14, weight: sex == s ? .bold : .medium))
                                    .foregroundStyle(sex == s ? .white : OPTheme.text)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(sex == s ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ОПИСАНИЕ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextEditor(text: $description)
                            .font(.system(size: 15))
                            .frame(minHeight: 80)
                            .padding(10)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Button {
                        let animal = ShelterAnimal(id: store.newId(), name: name, breed: breed, age: age, sex: sex, description: description, photoURL: URL(string: photoOptions[selectedPhotoIndex]), isAdopted: false, addedAt: Date())
                        store.addShelterAnimal(animal)
                        dismiss()
                    } label: {
                        Text("Добави куче")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                    }
                    .disabled(name.isEmpty || breed.isEmpty)
                    .opacity(name.isEmpty || breed.isEmpty ? 0.5 : 1)
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Ново куче")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Затвори") { dismiss() } } }
        }
    }
}

// MARK: - Role Switcher

struct DashboardRoleSwitcher: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack {
            OPWordmark(size: 15)
            Spacer()
            let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })
            Menu {
                ForEach(availableRoles, id: \.self) { role in
                    Button {
                        withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                    } label: {
                        Label(role.label, systemImage: role.icon)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: store.activeRole.icon)
                        .font(.system(size: 12, weight: .bold))
                    Text(store.activeRole.label)
                        .font(.system(size: 13, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(OPTheme.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(OPTheme.primarySoft, in: Capsule())
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Shared Dashboard Field

private func dashField(_ label: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(OPTheme.textSecondary)
            .tracking(0.5)
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(OPTheme.mint)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(14)
        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
