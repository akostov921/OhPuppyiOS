import SwiftUI

// MARK: - Shelter Dog Model

struct ShelterDog: Identifiable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let sex: String
    let description: String
    let photoURL: String
    let shelterName: String
    let location: String
    let isVaccinated: Bool
    let isNeutered: Bool
}

// MARK: - Shelters View

struct SheltersView: View {
    @State private var selectedFilter = "Всички"
    @State private var showDonateSheet = false
    @State private var selectedDog: ShelterDog?

    private let filters = ["Всички", "Малки", "Средни", "Големи", "Кученца"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 16)

                donationBanner
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 20)

                filterChips
                    .padding(.bottom, 16)

                dogsGrid
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationTitle("Осинови")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDonateSheet) {
            DonateSheet()
        }
        .sheet(item: $selectedDog) { dog in
            ShelterDogDetailSheet(dog: dog)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(OPTheme.rose)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Осинови кученце")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("\(shelterDogs.count) кучета търсят дом")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
        .padding(.top, 12)
    }

    // MARK: - Donation Banner

    private var donationBanner: some View {
        Button { showDonateSheet = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "gift.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Помогни с месечно дарение")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("От 5 лв/месец храниш едно куче")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.rose)
                    .frame(width: 28, height: 28)
                    .background(OPTheme.roseSoft, in: Circle())
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(OPTheme.roseSoft.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(OPTheme.rose.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(OPTheme.quickSpring) { selectedFilter = filter }
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: selectedFilter == filter ? .bold : .medium))
                            .foregroundStyle(selectedFilter == filter ? .white : OPTheme.text)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                in: Capsule()
                            )
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Dogs Grid

    private var dogsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
            ForEach(shelterDogs) { dog in
                Button { selectedDog = dog } label: {
                    shelterDogCard(dog)
                }
                .buttonStyle(PressableCardStyle())
            }
        }
    }

    private func shelterDogCard(_ dog: ShelterDog) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: dog.photoURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(OPTheme.surfaceSunken)
                            .overlay {
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(OPTheme.mint.opacity(0.3))
                            }
                    }
                }
                .frame(height: 140)
                .clipped()

                if dog.isVaccinated {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 9))
                        Text("Ваксиниран")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(OPTheme.success.opacity(0.85), in: Capsule())
                    .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dog.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)

                Text("\(dog.breed) · \(dog.age)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 9))
                    Text(dog.shelterName)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(OPTheme.textTertiary)
            }
            .padding(10)
        }
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }

    // MARK: - Mock Data

    private var shelterDogs: [ShelterDog] {
        [
            ShelterDog(id: "sd1", name: "Шаро", breed: "Микс", age: "2 г.", sex: "Мъжки", description: "Шаро е много приятелски и обича деца. Намерен на улицата преди 6 месеца, вече е напълно здрав и социализиран.", photoURL: "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=300&h=300&q=85", shelterName: "Приют Надежда", location: "София", isVaccinated: true, isNeutered: true),
            ShelterDog(id: "sd2", name: "Бела", breed: "Лабрадор микс", age: "1 г.", sex: "Женски", description: "Бела е енергично куче, което обожава да тича. Идеална за активно семейство.", photoURL: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=300&h=300&q=85", shelterName: "Четири лапи", location: "Пловдив", isVaccinated: true, isNeutered: false),
            ShelterDog(id: "sd3", name: "Макс", breed: "Овчарка микс", age: "4 г.", sex: "Мъжки", description: "Макс е спокоен и лоялен. Перфектен пазач и приятел.", photoURL: "https://images.unsplash.com/photo-1534361960057-19889db9621e?auto=format&fit=crop&w=300&h=300&q=85", shelterName: "Приют Надежда", location: "София", isVaccinated: true, isNeutered: true),
            ShelterDog(id: "sd4", name: "Лола", breed: "Териер микс", age: "8 м.", sex: "Женски", description: "Малка Лола търси любящ дом. Много игрива и любопитна.", photoURL: "https://images.unsplash.com/photo-1558788353-f76d92427f16?auto=format&fit=crop&w=300&h=300&q=85", shelterName: "Втори шанс", location: "Варна", isVaccinated: true, isNeutered: false),
            ShelterDog(id: "sd5", name: "Рико", breed: "Хъски микс", age: "3 г.", sex: "Мъжки", description: "Рико е красив и умен. Нуждае се от много движение и внимание.", photoURL: "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=300&h=300&q=85", shelterName: "Четири лапи", location: "Пловдив", isVaccinated: false, isNeutered: true),
            ShelterDog(id: "sd6", name: "Мими", breed: "Пинчер микс", age: "5 г.", sex: "Женски", description: "Мими е тиха и нежна. Обича да се гушка и да лежи до стопанина си.", photoURL: "https://images.unsplash.com/photo-1477884213360-7e9d7dcc8f9b?auto=format&fit=crop&w=300&h=300&q=85", shelterName: "Приют Надежда", location: "София", isVaccinated: true, isNeutered: true),
        ]
    }
}

// MARK: - Shelter Dog Detail Sheet

struct ShelterDogDetailSheet: View {
    let dog: ShelterDog
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showAdoptAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: dog.photoURL)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Rectangle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(dog.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Spacer()
                            if dog.isVaccinated {
                                StatPill(label: "Ваксиниран", icon: "checkmark.seal.fill", tone: .success)
                            }
                        }

                        HStack(spacing: 12) {
                            infoChip(icon: "pawprint.fill", text: dog.breed)
                            infoChip(icon: "calendar", text: dog.age)
                            infoChip(icon: dog.sex == "Мъжки" ? "figure.stand" : "figure.stand.dress", text: dog.sex)
                        }

                        if dog.isNeutered {
                            StatPill(label: "Кастриран", icon: "heart.fill", tone: .info)
                        }

                        Divider().padding(.vertical, 4)

                        Text("За \(dog.name)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text(dog.description)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(OPTheme.textSecondary)
                            .lineSpacing(3)

                        Divider().padding(.vertical, 4)

                        HStack(spacing: 10) {
                            Image(systemName: "building.2.fill")
                                .foregroundStyle(OPTheme.mint)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dog.shelterName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(OPTheme.text)
                                Text(dog.location)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, OPTheme.screenPadding)

                    Button { showAdoptAlert = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 15))
                            Text("Искам да осиновя \(dog.name)")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: OPTheme.rose.opacity(0.3), radius: 10, y: 4)
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 20)
                }
                .padding(.top, 16)
            }
            .background(OPTheme.bg)
            .navigationTitle(dog.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.primary)
                }
            }
            .alert("Заявка за осиновяване", isPresented: $showAdoptAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Заявката ти е изпратена до \(dog.shelterName). Ще се свържат с теб до 48 часа.")
            }
            .onChange(of: showAdoptAlert) { _, newValue in
                if newValue {
                    let request = AdoptionRequest(id: UUID().uuidString, animalId: dog.id, animalName: dog.name, requesterName: store.ownerName, requesterPhone: "+359 88 000 0000", requesterNote: "", status: .pending, submittedAt: Date())
                    store.adoptionRequests.append(request)
                    store.save()
                }
            }
        }
    }

    private func infoChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(OPTheme.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(OPTheme.surfaceSunken, in: Capsule())
    }
}

// MARK: - Donate Sheet

struct DonateSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount = 10
    @State private var showThankYou = false
    private let amounts = [5, 10, 20, 50]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Месечно дарение")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Помогни на кучетата без дом.\nСумата се добавя към абонамента ти.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                HStack(spacing: 12) {
                    ForEach(amounts, id: \.self) { amount in
                        Button {
                            withAnimation(OPTheme.quickSpring) { selectedAmount = amount }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(amount)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(selectedAmount == amount ? .white : OPTheme.text)
                                Text("лв/мес")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(selectedAmount == amount ? .white.opacity(0.8) : OPTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selectedAmount == amount ?
                                    AnyShapeStyle(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                                    AnyShapeStyle(OPTheme.surfaceSunken),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                            .shadow(color: selectedAmount == amount ? OPTheme.rose.opacity(0.3) : .clear, radius: 6, y: 3)
                        }
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)

                VStack(spacing: 8) {
                    infoRow(icon: "fork.knife", text: "5 лв = 1 ден храна за 1 куче")
                    infoRow(icon: "cross.vial.fill", text: "10 лв = ваксина за 1 куче")
                    infoRow(icon: "house.fill", text: "20 лв = 1 седмица подслон")
                    infoRow(icon: "stethoscope", text: "50 лв = ветеринарен преглед")
                }
                .padding(.horizontal, OPTheme.screenPadding)

                Spacer()

                Button {
                    let donation = Donation(id: UUID().uuidString, donorName: store.ownerName, amount: Double(selectedAmount), isRecurring: true, date: Date(), note: nil)
                    store.addDonation(donation)
                    showThankYou = true
                } label: {
                    Text("Дари \(selectedAmount) лв/месец")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: OPTheme.rose.opacity(0.3), radius: 10, y: 4)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 20)
            }
            .background(OPTheme.bg)
            .navigationTitle("Дарение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
            .alert("Благодарим ти!", isPresented: $showThankYou) {
                Button("OK") { dismiss() }
            } message: {
                Text("Дарението от \(selectedAmount) лв/месец е активирано. Ще помогнеш на много кучета!")
            }
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(OPTheme.rose)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Spacer()
        }
    }
}
