import SwiftUI

struct DogListView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddDog = false
    @State private var pressedId: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Моите кучета")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("\(store.dogs.count) от семейството")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    Spacer()
                    Button {
                        withAnimation(OPTheme.springAnimation) {
                            showAddDog = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, value: showAddDog)
                            .frame(width: 42, height: 42)
                            .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: OPTheme.primary.opacity(0.3), radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Dog Cards
                VStack(spacing: 14) {
                    ForEach(store.dogs) { dog in
                        NavigationLink(destination: DogProfileView(dog: dog)) {
                            dogCard(dog)
                        }
                        .buttonStyle(PressableCardStyle())
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .slide))
                    }

                    // Add button
                    Button {
                        withAnimation(OPTheme.springAnimation) {
                            showAddDog = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                            Text("Добави куче")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(OPTheme.mint)
                        .frame(maxWidth: .infinity)
                        .padding(22)
                        .background(
                            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                                .strokeBorder(OPTheme.mint.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        )
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddDog) {
            AddDogView()
        }
    }

    private func dogCard(_ dog: Dog) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: dog.avatarURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(OPTheme.mint.opacity(0.5))
                        }
                }
            }
            .frame(width: 110, height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(dog.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)

                Text(dog.breed)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)

                Text("\(dog.age) \u{00B7} \(String(format: "%.1f", dog.weight)) кг")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
                    .padding(.top, 1)

                vaccineStatus(for: dog)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(OPTheme.textTertiary)
                .padding(.trailing, 14)
        }
        .frame(minHeight: 120)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 10, y: 4)
    }

    @ViewBuilder
    private func vaccineStatus(for dog: Dog) -> some View {
        let hasOverdue = store.vaccinesFor(dogId: dog.id).contains { v in
            if let due = v.nextDueDate { return due < Date() }
            return false
        }
        let upcoming = store.upcomingVaccines(dogId: dog.id)
        let hasSoon = upcoming.contains { v in
            if let due = v.nextDueDate { return due.daysFromNow <= 7 && due.daysFromNow >= 0 }
            return false
        }

        if hasOverdue {
            StatPill(label: "Просрочена", icon: "exclamationmark.circle.fill", tone: .danger)
        } else if hasSoon {
            StatPill(label: "Скоро ваксина", icon: "clock.fill", tone: .warning)
        } else {
            StatPill(label: "В ред", icon: "checkmark.circle.fill", tone: .success)
        }
    }
}
