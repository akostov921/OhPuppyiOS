import SwiftUI

struct EventsView: View {
    @Environment(AppStore.self) private var store
    @State private var goingSet: Set<String> = ["e1"]
    @State private var showCreateEvent = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                eventsHeader
                    .padding(.bottom, 16)

                ForEach(allEvents) { event in
                    EventCard(event: event, isGoing: goingSet.contains(event.id)) {
                        withAnimation(OPTheme.quickSpring) {
                            if goingSet.contains(event.id) {
                                goingSet.remove(event.id)
                            } else {
                                goingSet.insert(event.id)
                            }
                        }
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 14)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateEvent) {
            CreateEventSheet()
        }
    }

    private var allEvents: [DogEvent] {
        mockEvents + store.userEvents
    }

    // MARK: - Header

    private var eventsHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Събития")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("Наблизо тази седмица")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            Button { showCreateEvent = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: OPTheme.primary.opacity(0.3), radius: 6, y: 3)
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Mock Data

    private var mockEvents: [DogEvent] {
        [
            DogEvent(
                id: "e1",
                title: "Среща на лабрадори",
                dayNumber: "25",
                monthLabel: "май",
                dateTimeText: "Сб 25 май, 10:00",
                location: "Южен парк",
                attending: 12,
                capacity: 20
            ),
            DogEvent(
                id: "e2",
                title: "Сутрешна разходка",
                dayNumber: "26",
                monthLabel: "май",
                dateTimeText: "Нед 26 май, 08:00",
                location: "Витоша",
                attending: 4,
                capacity: 10
            ),
            DogEvent(
                id: "e3",
                title: "Купон за рожден ден",
                dayNumber: "1",
                monthLabel: "юни",
                dateTimeText: "Сб 1 юни, 14:00",
                location: "Кафе Тарантула",
                attending: 8,
                capacity: 15
            ),
        ]
    }
}

// MARK: - Event Model

struct DogEvent: Identifiable {
    let id: String
    let title: String
    let dayNumber: String
    let monthLabel: String
    let dateTimeText: String
    let location: String
    let attending: Int
    let capacity: Int
}

// MARK: - Create Event Sheet

struct CreateEventSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var maxAttendees = 10

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Заглавие")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Име на събитието", text: $title)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Какво ще правим?", text: $description, axis: .vertical)
                            .font(.system(size: 16))
                            .lineLimit(3...5)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дата и час")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Локация")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Къде ще се проведе?", text: $location)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Максимум участници")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        Stepper(value: $maxAttendees, in: 2...50) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(OPTheme.mint)
                                Text("\(maxAttendees) кучета")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(OPTheme.text)
                            }
                        }
                        .padding(14)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Ново събитие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Създай") {
                        createEvent()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(title.isEmpty ? OPTheme.textTertiary : OPTheme.primary)
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func createEvent() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "bg_BG")

        formatter.dateFormat = "d"
        let dayNum = formatter.string(from: date)

        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)

        formatter.dateFormat = "EEE d MMM, HH:mm"
        let dateTimeText = formatter.string(from: date)

        let event = DogEvent(
            id: UUID().uuidString,
            title: title,
            dayNumber: dayNum,
            monthLabel: month,
            dateTimeText: dateTimeText,
            location: location.isEmpty ? "Не е посочена" : location,
            attending: 1,
            capacity: maxAttendees
        )
        store.addEvent(event)
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: DogEvent
    let isGoing: Bool
    let onToggleRSVP: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Date block
            VStack(spacing: 2) {
                Text(event.dayNumber)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(isGoing ? .white : OPTheme.text)
                Text(event.monthLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isGoing ? .white.opacity(0.85) : OPTheme.textSecondary)
                    .textCase(.uppercase)
            }
            .frame(width: 56, height: 60)
            .background(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous)
                    .fill(isGoing ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken))
            )

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)

                    Spacer()

                    Button {
                        onToggleRSVP()
                    } label: {
                        Text(isGoing ? "Отивам" : "Запиши ме")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isGoing ? .white : OPTheme.mint)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                isGoing ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.mintSoft),
                                in: Capsule()
                            )
                    }
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(OPTheme.textTertiary)
                        Text(event.dateTimeText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text(event.location)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                // Attendees
                HStack(spacing: 8) {
                    // Avatar stack
                    HStack(spacing: -8) {
                        Circle()
                            .fill(OPTheme.mint)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                        Circle()
                            .fill(OPTheme.accent)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                        Circle()
                            .fill(OPTheme.sky)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                    }

                    Text("\(event.attending) / \(event.capacity) кучета")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }
        }
        .padding(14)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(isGoing ? OPTheme.mint.opacity(0.3) : OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 10, y: 4)
    }
}
