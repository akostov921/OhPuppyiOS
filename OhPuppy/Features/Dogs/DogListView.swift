import SwiftUI

struct DogListView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddDog = false
    @State private var isGridView = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
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
                        withAnimation(OPTheme.quickSpring) { isGridView.toggle() }
                    } label: {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                            .frame(width: 42, height: 42)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

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

                Group {
                    if isGridView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                            ForEach(store.dogs) { dog in
                                NavigationLink(destination: DogProfileView(dog: dog)) {
                                    dogGridCard(dog)
                                }
                                .buttonStyle(PressableCardStyle())
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            ForEach(store.dogs) { dog in
                                NavigationLink(destination: DogProfileView(dog: dog)) {
                                    dogCard(dog)
                                }
                                .buttonStyle(PressableCardStyle())
                            }
                        }
                    }
                }
                .animation(OPTheme.quickSpring, value: isGridView)

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
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(OPTheme.mint.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        )
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
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: dog.avatarURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(OPTheme.mint.opacity(0.3))
                        }
                }
            }
            .frame(height: 200)
            .clipped()

            LinearGradient(
                colors: [.black.opacity(0.7), .black.opacity(0.3), .clear],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 6) {
                vaccineStatus(for: dog)

                Text(dog.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Text(dog.breed)
                        .font(.system(size: 13, weight: .semibold))
                    Text("·")
                    Text(dog.age)
                        .font(.system(size: 13, weight: .medium))
                    Text("·")
                    Text("\(String(format: "%.1f", dog.weight)) кг")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: OPTheme.primary.opacity(0.12), radius: 12, y: 6)
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
            statusPill(label: "Просрочена", icon: "exclamationmark.circle.fill", color: OPTheme.danger)
        } else if hasSoon {
            statusPill(label: "Скоро ваксина", icon: "clock.fill", color: OPTheme.warning)
        } else {
            statusPill(label: "В ред", icon: "checkmark.circle.fill", color: OPTheme.success)
        }
    }

    private func dogGridCard(_ dog: Dog) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: dog.avatarURL) { phase in
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
                .frame(height: 150)
                .clipped()

                vaccineStatus(for: dog)
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dog.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("\(dog.breed) · \(dog.age)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                Text("\(String(format: "%.1f", dog.weight)) кг")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            .padding(10)
        }
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 8, y: 3)
    }

    private func statusPill(label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text(label)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.85), in: Capsule())
    }
}
