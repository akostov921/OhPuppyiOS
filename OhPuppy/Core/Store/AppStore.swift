import Foundation
import Observation

struct NotificationSettings {
    var vaccineReminders: Bool = true
    var chatNotifications: Bool = true
    var lostDogAlerts: Bool = true
}

enum LocationPrecision: String, CaseIterable {
    case exact = "Точна"
    case approximate = "Приблизителна"
    case hidden = "Скрита"
}

@Observable
final class AppStore {
    var dogs: [Dog]
    var vaccines: [Vaccine]
    var weights: [WeightLog]
    var grooming: [GroomingLog]
    var vetVisits: [VetVisit]
    var medications: [Medication]
    var lostDogAlerts: [LostDogAlert]
    var diaryEntries: [DiaryEntry]
    var milestones: [Milestone]

    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false

    // Profile
    var ownerName: String = "Мария"
    var ownerBio: String = ""
    var ownerEmail: String = "maria@ohpuppy.bg"

    // Settings
    var isDarkMode: Bool = false
    var language: String = "bg"
    var notificationSettings: NotificationSettings = NotificationSettings()
    var locationPrecision: LocationPrecision = .exact
    var showOnMap: Bool = true

    // Events (user-created)
    var userEvents: [DogEvent] = []

    // Stories
    var stories: [Story]
    var myStories: [Story] = []

    // Dog Status
    var currentDogStatus: (dogId: String, statusId: String, setAt: Date)?

    private var nextId = 100

    init() {
        let cal = Calendar.current

        self.dogs = [
            Dog(id: "1", name: "Рекс", breed: "Лабрадор", birthDate: cal.date(from: DateComponents(year: 2022, month: 4, day: 12))!, sex: .male, neutered: true, weight: 14.2, microchip: "900164001234567", bio: "Обича разходки в Борисова градина.", avatarURL: URL(string: "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=400&h=400&q=85"), ownerId: "1"),
            Dog(id: "2", name: "Луна", breed: "Френски булдог", birthDate: cal.date(from: DateComponents(year: 2024, month: 6, day: 1))!, sex: .female, neutered: false, weight: 9.4, avatarURL: URL(string: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=400&h=400&q=85"), ownerId: "1"),
            Dog(id: "3", name: "Бисквит", breed: "Голдън ретривър", birthDate: cal.date(from: DateComponents(year: 2025, month: 10, day: 15))!, sex: .male, neutered: false, weight: 18.0, avatarURL: URL(string: "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=400&h=400&q=85"), ownerId: "1"),
        ]

        self.vaccines = [
            Vaccine(id: "v1", dogId: "1", type: .rabies, dateAdministered: cal.date(from: DateComponents(year: 2025, month: 5, day: 15))!, nextDueDate: cal.date(from: DateComponents(year: 2026, month: 5, day: 30))!, vet: "Д-р Илиян Иванов", clinic: "Ветеринарна клиника Лапа"),
            Vaccine(id: "v2", dogId: "1", type: .dhppl, dateAdministered: cal.date(from: DateComponents(year: 2025, month: 4, day: 10))!, nextDueDate: cal.date(from: DateComponents(year: 2026, month: 7, day: 18))!),
            Vaccine(id: "v3", dogId: "1", type: .bordetella, dateAdministered: cal.date(from: DateComponents(year: 2025, month: 4, day: 10))!, nextDueDate: cal.date(from: DateComponents(year: 2025, month: 10, day: 10))!),
            Vaccine(id: "v4", dogId: "1", type: .deworming, dateAdministered: cal.date(from: DateComponents(year: 2026, month: 5, day: 20))!, nextDueDate: cal.date(from: DateComponents(year: 2026, month: 8, day: 20))!),
            Vaccine(id: "v5", dogId: "1", type: .rabies, dateAdministered: cal.date(from: DateComponents(year: 2024, month: 5, day: 15))!),
        ]

        self.weights = [
            WeightLog(id: "w1", dogId: "1", weight: 12.4, date: cal.date(from: DateComponents(year: 2025, month: 12, day: 1))!),
            WeightLog(id: "w2", dogId: "1", weight: 12.8, date: cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!),
            WeightLog(id: "w3", dogId: "1", weight: 13.0, date: cal.date(from: DateComponents(year: 2026, month: 2, day: 1))!),
            WeightLog(id: "w4", dogId: "1", weight: 13.4, date: cal.date(from: DateComponents(year: 2026, month: 3, day: 1))!),
            WeightLog(id: "w5", dogId: "1", weight: 13.8, date: cal.date(from: DateComponents(year: 2026, month: 4, day: 1))!),
            WeightLog(id: "w6", dogId: "1", weight: 14.2, date: cal.date(from: DateComponents(year: 2026, month: 5, day: 20))!),
        ]

        self.grooming = [
            GroomingLog(id: "g1", dogId: "1", type: .bath, date: cal.date(from: DateComponents(year: 2026, month: 5, day: 12))!, notes: "Шампоан за къса козина"),
            GroomingLog(id: "g2", dogId: "1", type: .nails, date: cal.date(from: DateComponents(year: 2026, month: 5, day: 1))!),
        ]

        self.vetVisits = [
            VetVisit(id: "vv1", dogId: "1", date: cal.date(from: DateComponents(year: 2026, month: 5, day: 14))!, reason: "Преглед за апатия", diagnosis: "Лек гастрит — диета 3 дни", vet: "Д-р Илиян Иванов", clinic: "Клиника Лапа", price: 85),
            VetVisit(id: "vv2", dogId: "1", date: cal.date(from: DateComponents(year: 2026, month: 3, day: 2))!, reason: "Годишен преглед", diagnosis: "Здрав — Rabies + DHPPL", vet: "Д-р Илиян Иванов", clinic: "Клиника Лапа", price: 120),
            VetVisit(id: "vv3", dogId: "1", date: cal.date(from: DateComponents(year: 2025, month: 11, day: 11))!, reason: "Куца — лява задна", diagnosis: "Лек удар, без счупване. Carprofen 5 дни", vet: "Д-р Е. Колева", clinic: "СПА Pets", price: 140),
        ]

        self.medications = [
            Medication(id: "med1", dogId: "1", name: "Frontline Combo", dose: "1 пипета", frequency: .monthly, startDate: cal.date(from: DateComponents(year: 2026, month: 4, day: 1))!, endDate: nil),
            Medication(id: "med2", dogId: "1", name: "Carprofen 50 mg", dose: "1 таблетка", frequency: .twiceDaily, startDate: cal.date(from: DateComponents(year: 2026, month: 5, day: 20))!, endDate: cal.date(from: DateComponents(year: 2026, month: 5, day: 27))!),
            Medication(id: "med3", dogId: "1", name: "Drontal", dose: "1 таблетка", frequency: .asNeeded, startDate: cal.date(from: DateComponents(year: 2026, month: 5, day: 1))!, endDate: cal.date(from: DateComponents(year: 2026, month: 5, day: 1))!),
        ]

        self.lostDogAlerts = []

        self.diaryEntries = [
            DiaryEntry(id: "d1", dogId: "1", text: "Първа разходка в Южен парк! Рекс беше толкова щастлив.", date: cal.date(from: DateComponents(year: 2026, month: 5, day: 18))!),
            DiaryEntry(id: "d2", dogId: "1", text: "Научи нова команда — \"дай лапа\"! Горд съм.", date: cal.date(from: DateComponents(year: 2026, month: 5, day: 10))!),
            DiaryEntry(id: "d3", dogId: "1", text: "Среща с други лабрадори в парка. Игра 2 часа!", date: cal.date(from: DateComponents(year: 2026, month: 4, day: 28))!),
        ]

        self.milestones = [
            Milestone(id: "m1", dogId: "1", emoji: "🏠", title: "1 година с нас", date: cal.date(from: DateComponents(year: 2023, month: 4, day: 12))!, notes: nil, isCustom: false),
            Milestone(id: "m2", dogId: "1", emoji: "🦷", title: "Смяна на зъби", date: cal.date(from: DateComponents(year: 2022, month: 9, day: 12))!, notes: "Около 5-месечна възраст", isCustom: false),
            Milestone(id: "m3", dogId: "1", emoji: "🐕", title: "Вече е възрастен!", date: cal.date(from: DateComponents(year: 2024, month: 4, day: 12))!, notes: "Лабрадорите стават възрастни около 2 години", isCustom: false),
            Milestone(id: "m4", dogId: "1", emoji: "🏊", title: "Първо плуване", date: cal.date(from: DateComponents(year: 2025, month: 7, day: 20))!, notes: "В езерото до Панчарево", isCustom: true),
        ]

        self.stories = [
            Story(id: "s1", dogName: "Тоби", ownerName: "Петър", photoURL: URL(string: "https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Първи плувен ден! 🌊", timestamp: Date().addingTimeInterval(-3600), isSeen: false),
            Story(id: "s2", dogName: "Мила", ownerName: "Ана", photoURL: URL(string: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Нов шампоан, нов живот 🧴", timestamp: Date().addingTimeInterval(-7200), isSeen: false),
            Story(id: "s3", dogName: "Локи", ownerName: "Марко", photoURL: URL(string: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Витоша днес 🏔", timestamp: Date().addingTimeInterval(-10800), isSeen: false),
            Story(id: "s4", dogName: "Чарли", ownerName: "Иван", photoURL: URL(string: "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Снежен ден ❄️", timestamp: Date().addingTimeInterval(-14400), isSeen: false),
        ]
    }

    // MARK: - Dogs

    func addDog(_ dog: Dog) {
        dogs.append(dog)
    }

    func updateDog(_ dog: Dog) {
        if let i = dogs.firstIndex(where: { $0.id == dog.id }) {
            dogs[i] = dog
        }
    }

    func deleteDog(id: String) {
        dogs.removeAll { $0.id == id }
        vaccines.removeAll { $0.dogId == id }
        weights.removeAll { $0.dogId == id }
        grooming.removeAll { $0.dogId == id }
        vetVisits.removeAll { $0.dogId == id }
        medications.removeAll { $0.dogId == id }
        lostDogAlerts.removeAll { $0.dogId == id }
    }

    // MARK: - Vaccines

    func vaccinesFor(dogId: String) -> [Vaccine] {
        vaccines.filter { $0.dogId == dogId }
    }

    func upcomingVaccines(dogId: String) -> [Vaccine] {
        let now = Date()
        return vaccinesFor(dogId: dogId)
            .filter { $0.nextDueDate != nil && $0.nextDueDate! >= now }
            .sorted { ($0.nextDueDate ?? .distantFuture) < ($1.nextDueDate ?? .distantFuture) }
    }

    func pastVaccines(dogId: String) -> [Vaccine] {
        let now = Date()
        return vaccinesFor(dogId: dogId)
            .filter { $0.nextDueDate == nil || $0.nextDueDate! < now }
    }

    func nextDueVaccine(dogId: String) -> Vaccine? {
        upcomingVaccines(dogId: dogId).first
    }

    func addVaccine(_ vaccine: Vaccine) {
        vaccines.append(vaccine)
    }

    // MARK: - Weight

    func weightsFor(dogId: String) -> [WeightLog] {
        weights.filter { $0.dogId == dogId }.sorted { $0.date < $1.date }
    }

    func addWeight(_ entry: WeightLog) {
        weights.append(entry)
        if let i = dogs.firstIndex(where: { $0.id == entry.dogId }) {
            dogs[i].weight = entry.weight
        }
    }

    // MARK: - Grooming

    func groomingFor(dogId: String) -> [GroomingLog] {
        grooming.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addGrooming(_ entry: GroomingLog) {
        grooming.append(entry)
    }

    // MARK: - Vet Visits

    func vetVisitsFor(dogId: String) -> [VetVisit] {
        vetVisits.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addVetVisit(_ visit: VetVisit) {
        vetVisits.append(visit)
    }

    // MARK: - Medications

    func medicationsFor(dogId: String) -> [Medication] {
        medications.filter { $0.dogId == dogId }.sorted { $0.startDate > $1.startDate }
    }

    func addMedication(_ med: Medication) {
        medications.append(med)
    }

    // MARK: - Diary Entries

    func diaryEntriesFor(dogId: String) -> [DiaryEntry] {
        diaryEntries.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.append(entry)
    }

    // MARK: - Milestones

    func milestonesFor(dogId: String) -> [Milestone] {
        milestones.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addMilestone(_ milestone: Milestone) {
        milestones.append(milestone)
    }

    // MARK: - Lost Dog Alerts

    func addLostDogAlert(_ alert: LostDogAlert) {
        lostDogAlerts.append(alert)
    }

    // MARK: - Events

    func addEvent(_ event: DogEvent) {
        userEvents.append(event)
    }

    // MARK: - Health Score

    func healthScore(for dogId: String) -> Int {
        let breakdown = healthBreakdown(for: dogId)
        return breakdown.reduce(0) { $0 + $1.score }
    }

    func healthBreakdown(for dogId: String) -> [(category: String, score: Int, maxScore: Int, status: String)] {
        let now = Date()
        let cal = Calendar.current
        var results: [(category: String, score: Int, maxScore: Int, status: String)] = []

        // 1. Vaccines (30 points)
        let vaccines = vaccinesFor(dogId: dogId)
        let overdueCount = vaccines.filter { v in
            guard let due = v.nextDueDate else { return false }
            return due < now
        }.count
        let vaccineScore = max(0, 30 - (overdueCount * 10))
        let vaccineStatus = overdueCount == 0 ? "good" : overdueCount == 1 ? "warning" : "bad"
        results.append((category: "Ваксини", score: vaccineScore, maxScore: 30, status: vaccineStatus))

        // 2. Weight in breed range (25 points)
        guard let dog = dogs.first(where: { $0.id == dogId }) else {
            return results
        }
        let breedRange = breedWeightRange(for: dog.breed)
        let lowerBound = breedRange.0
        let upperBound = breedRange.1
        let tolerance = 0.15
        let adjustedLower = lowerBound * (1 - tolerance)
        let adjustedUpper = upperBound * (1 + tolerance)
        let weightScore: Int
        if dog.weight >= adjustedLower && dog.weight <= adjustedUpper {
            weightScore = 25
        } else {
            let distanceFromRange: Double
            if dog.weight < adjustedLower {
                distanceFromRange = (adjustedLower - dog.weight) / adjustedLower
            } else {
                distanceFromRange = (dog.weight - adjustedUpper) / adjustedUpper
            }
            weightScore = max(0, 25 - Int(distanceFromRange * 50))
        }
        let weightStatus = weightScore >= 20 ? "good" : weightScore >= 10 ? "warning" : "bad"
        results.append((category: "Тегло", score: weightScore, maxScore: 25, status: weightStatus))

        // 3. Recent vet visit (25 points)
        let visits = vetVisitsFor(dogId: dogId)
        let vetScore: Int
        if let lastVisit = visits.first {
            let months = cal.dateComponents([.month], from: lastVisit.date, to: now).month ?? 99
            if months <= 6 {
                vetScore = 25
            } else if months <= 12 {
                vetScore = 15
            } else {
                vetScore = 5
            }
        } else {
            vetScore = 0
        }
        let vetStatus = vetScore >= 20 ? "good" : vetScore >= 10 ? "warning" : "bad"
        results.append((category: "Ветеринар", score: vetScore, maxScore: 25, status: vetStatus))

        // 4. Grooming current (10 points)
        let groomLogs = groomingFor(dogId: dogId)
        let groomScore: Int
        if let lastGroom = groomLogs.first {
            let days = cal.dateComponents([.day], from: lastGroom.date, to: now).day ?? 999
            if days <= 30 {
                groomScore = 10
            } else if days <= 60 {
                groomScore = 5
            } else {
                groomScore = 2
            }
        } else {
            groomScore = 0
        }
        let groomStatus = groomScore >= 8 ? "good" : groomScore >= 4 ? "warning" : "bad"
        results.append((category: "Гриминг", score: groomScore, maxScore: 10, status: groomStatus))

        // 5. Active medications tracked (10 points)
        let meds = medicationsFor(dogId: dogId)
        let activeMeds = meds.filter(\.isActive)
        let overdueMeds = activeMeds.filter { med in
            if let end = med.endDate, end < now { return true }
            return false
        }
        let medScore = overdueMeds.isEmpty ? 10 : max(0, 10 - overdueMeds.count * 5)
        let medStatus = medScore >= 8 ? "good" : medScore >= 4 ? "warning" : "bad"
        results.append((category: "Лекарства", score: medScore, maxScore: 10, status: medStatus))

        return results
    }

    private func breedWeightRange(for breed: String) -> (Double, Double) {
        switch breed {
        case "Лабрадор": return (25.0, 36.0)
        case "Френски булдог": return (8.0, 14.0)
        case "Голдън ретривър": return (25.0, 34.0)
        default: return (5.0, 40.0)
        }
    }

    // MARK: - Auth

    func signIn() {
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // MARK: - Stories

    func addStory(caption: String) {
        let story = Story(
            id: newId(),
            dogName: dogs.first?.name ?? "Рекс",
            ownerName: ownerName,
            photoURL: URL(string: "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&h=1200&q=85"),
            caption: caption,
            timestamp: Date(),
            isSeen: false
        )
        myStories.append(story)
    }

    func markStorySeen(id: String) {
        if let i = stories.firstIndex(where: { $0.id == id }) {
            stories[i].isSeen = true
        }
    }

    // MARK: - Dog Status

    func setDogStatus(dogId: String, statusId: String) {
        currentDogStatus = (dogId: dogId, statusId: statusId, setAt: Date())
    }

    func clearDogStatus() {
        currentDogStatus = nil
    }

    // MARK: - ID generation

    func newId() -> String {
        nextId += 1
        return String(nextId)
    }
}
