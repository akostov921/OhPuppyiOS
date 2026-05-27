import Foundation
import Observation
import UserNotifications
import CoreLocation

// MARK: - Location Manager

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}

// MARK: - Settings

struct NotificationSettings: Codable {
    var vaccineReminders: Bool = true
    var chatNotifications: Bool = true
    var lostDogAlerts: Bool = true
}

enum LocationPrecision: String, CaseIterable, Codable {
    case exact = "Точна"
    case approximate = "Приблизителна"
    case hidden = "Скрита"
}

struct SavedDogStatus: Codable {
    let dogId: String
    let statusId: String
    let setAt: Date
}

private struct SavedState: Codable {
    var dogs: [Dog]
    var vaccines: [Vaccine]
    var weights: [WeightLog]
    var grooming: [GroomingLog]
    var vetVisits: [VetVisit]
    var medications: [Medication]
    var lostDogAlerts: [LostDogAlert]
    var diaryEntries: [DiaryEntry]
    var milestones: [Milestone]
    var myStories: [Story]
    var userEvents: [DogEvent]
    var stories: [Story]
    var currentDogStatus: SavedDogStatus?
    var walkerApplication: WalkerApplication?
    var registeredRoles: [UserRole]?
    var vetServices: [VetService]?
    var brandProducts: [BrandProduct]?
    var shelterAnimals: [ShelterAnimal]?
    var walkerPoints: Int?
    var walkerWalksCount: Int?
    var walkerReviews: [WalkerDashReview]?
    var walkRequests: [WalkRequest]?
    var walkerEarnings: [WalkerEarning]?
    var vetAppointments: [VetAppointment]?
    var orders: [Order]?
    var brandOrders: [BrandOrder]?
    var adoptionRequests: [AdoptionRequest]?
    var shelterDonations: [Donation]?
    var appNotifications: [AppNotification]?
    var nextId: Int
}

// MARK: - Photo Storage

enum PhotoStorage {
    static let directory: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DogPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    static func save(imageData: Data, for dogId: String) -> URL {
        let filename = "\(dogId)_\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(filename)
        try? imageData.write(to: url)
        return url
    }

    static func delete(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
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

    var isAuthenticated: Bool {
        didSet { UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated") }
    }
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    var hasSelectedInitialRole: Bool {
        didSet { UserDefaults.standard.set(hasSelectedInitialRole, forKey: "hasSelectedInitialRole") }
    }

    var ownerName: String {
        didSet { UserDefaults.standard.set(ownerName, forKey: "ownerName"); save() }
    }
    var ownerBio: String {
        didSet { UserDefaults.standard.set(ownerBio, forKey: "ownerBio") }
    }
    var ownerEmail: String {
        didSet { UserDefaults.standard.set(ownerEmail, forKey: "ownerEmail") }
    }

    var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }
    var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "language") }
    }
    var notificationSettings: NotificationSettings {
        didSet {
            if let data = try? JSONEncoder().encode(notificationSettings) {
                UserDefaults.standard.set(data, forKey: "notificationSettings")
            }
            scheduleVaccineNotifications()
        }
    }
    var locationPrecision: LocationPrecision {
        didSet { UserDefaults.standard.set(locationPrecision.rawValue, forKey: "locationPrecision") }
    }
    var showOnMap: Bool {
        didSet { UserDefaults.standard.set(showOnMap, forKey: "showOnMap") }
    }
    var activeRole: UserRole {
        didSet { UserDefaults.standard.set(activeRole.rawValue, forKey: "activeRole") }
    }
    var savedCardLast4: String {
        didSet { UserDefaults.standard.set(savedCardLast4, forKey: "savedCardLast4") }
    }
    var savedDeliveryAddress: String {
        didSet { UserDefaults.standard.set(savedDeliveryAddress, forKey: "savedDeliveryAddress") }
    }
    var acceptsWalkOffers: Bool {
        didSet { UserDefaults.standard.set(acceptsWalkOffers, forKey: "acceptsWalkOffers") }
    }

    var userEvents: [DogEvent] = []
    var stories: [Story]
    var myStories: [Story] = []
    var currentDogStatus: (dogId: String, statusId: String, setAt: Date)?
    var walkerApplication: WalkerApplication?
    var homeSectionOrder: [HomeSection] {
        didSet {
            if let data = try? JSONEncoder().encode(homeSectionOrder) {
                UserDefaults.standard.set(data, forKey: "homeSectionOrder")
            }
        }
    }

    var registeredRoles: Set<UserRole> = []
    var vetServices: [VetService] = []
    var brandProducts: [BrandProduct] = []
    var shelterAnimals: [ShelterAnimal] = []
    var walkerPoints: Int = 0
    var walkerWalksCount: Int = 0
    var walkerReviews: [WalkerDashReview] = []

    var walkRequests: [WalkRequest] = []
    var walkerEarnings: [WalkerEarning] = []
    var vetAppointments: [VetAppointment] = []
    var orders: [Order] = []
    var brandOrders: [BrandOrder] = []
    var adoptionRequests: [AdoptionRequest] = []
    var shelterDonations: [Donation] = []
    var appNotifications: [AppNotification] = []

    var vetAcceptsOnlineBooking: Bool {
        didSet { UserDefaults.standard.set(vetAcceptsOnlineBooking, forKey: "vetAcceptsOnlineBooking") }
    }
    var walkerAcceptsOnlineRequests: Bool {
        didSet { UserDefaults.standard.set(walkerAcceptsOnlineRequests, forKey: "walkerAcceptsOnlineRequests") }
    }

    var unreadNotificationCount: Int {
        appNotifications.filter { !$0.isRead }.count
    }

    var upcomingWalks: [WalkRequest] { walkRequests.filter { $0.status == .accepted } }
    var completedWalks: [WalkRequest] { walkRequests.filter { $0.status == .completed } }
    var walkerTotalEarned: Double { walkerEarnings.reduce(0) { $0 + $1.amount } }
    var walkerPendingEarnings: Double { walkerEarnings.filter { $0.status == .held }.reduce(0) { $0 + $1.amount } }
    var walkerAvailableEarnings: Double { walkerEarnings.filter { $0.status == .available }.reduce(0) { $0 + $1.amount } }

    var currentWalkerBadge: WalkerBadge {
        WalkerBadge.allCases.last(where: { walkerPoints >= $0.minPoints }) ?? .newcomer
    }

    var nextWalkerBadge: WalkerBadge? {
        WalkerBadge.allCases.first(where: { $0.minPoints > walkerPoints })
    }

    private var nextId = 100

    private static let saveURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ohpuppy_data.json")
    }()

    init() {
        let defaults = UserDefaults.standard
        self.isAuthenticated = defaults.bool(forKey: "isAuthenticated")
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        self.hasSelectedInitialRole = defaults.bool(forKey: "hasSelectedInitialRole")
        self.ownerName = defaults.string(forKey: "ownerName").flatMap { $0.isEmpty ? nil : $0 } ?? "Apostol"
        self.ownerEmail = defaults.string(forKey: "ownerEmail") ?? ""
        self.ownerBio = defaults.string(forKey: "ownerBio") ?? ""
        self.isDarkMode = defaults.bool(forKey: "isDarkMode")
        self.language = defaults.string(forKey: "language") ?? "bg"
        self.showOnMap = defaults.object(forKey: "showOnMap") == nil ? true : defaults.bool(forKey: "showOnMap")
        self.activeRole = UserRole(rawValue: defaults.string(forKey: "activeRole") ?? "owner") ?? .owner
        self.savedCardLast4 = defaults.string(forKey: "savedCardLast4") ?? ""
        self.savedDeliveryAddress = defaults.string(forKey: "savedDeliveryAddress") ?? ""
        self.acceptsWalkOffers = defaults.bool(forKey: "acceptsWalkOffers")
        self.vetAcceptsOnlineBooking = defaults.object(forKey: "vetAcceptsOnlineBooking") == nil ? true : defaults.bool(forKey: "vetAcceptsOnlineBooking")
        self.walkerAcceptsOnlineRequests = defaults.object(forKey: "walkerAcceptsOnlineRequests") == nil ? true : defaults.bool(forKey: "walkerAcceptsOnlineRequests")
        self.locationPrecision = LocationPrecision(rawValue: defaults.string(forKey: "locationPrecision") ?? "Точна") ?? .exact

        if let sectionData = defaults.data(forKey: "homeSectionOrder"),
           let sections = try? JSONDecoder().decode([HomeSection].self, from: sectionData) {
            self.homeSectionOrder = sections
        } else {
            self.homeSectionOrder = HomeSection.allCases
        }

        if let notifData = defaults.data(forKey: "notificationSettings"),
           let settings = try? JSONDecoder().decode(NotificationSettings.self, from: notifData) {
            self.notificationSettings = settings
        } else {
            self.notificationSettings = NotificationSettings()
        }

        if let data = try? Data(contentsOf: Self.saveURL),
           let state = try? JSONDecoder().decode(SavedState.self, from: data) {
            self.dogs = state.dogs
            self.vaccines = state.vaccines
            self.weights = state.weights
            self.grooming = state.grooming
            self.vetVisits = state.vetVisits
            self.medications = state.medications
            self.lostDogAlerts = state.lostDogAlerts
            self.diaryEntries = state.diaryEntries
            self.milestones = state.milestones
            self.myStories = state.myStories
            self.userEvents = state.userEvents
            self.stories = state.stories
            self.nextId = state.nextId
            if let s = state.currentDogStatus {
                self.currentDogStatus = (dogId: s.dogId, statusId: s.statusId, setAt: s.setAt)
            }
            self.walkerApplication = state.walkerApplication
            self.registeredRoles = Set(state.registeredRoles ?? [])
            self.vetServices = state.vetServices ?? []
            self.brandProducts = state.brandProducts ?? []
            self.shelterAnimals = state.shelterAnimals ?? []
            self.walkerPoints = state.walkerPoints ?? 0
            self.walkerWalksCount = state.walkerWalksCount ?? 0
            self.walkerReviews = state.walkerReviews ?? []
            self.walkRequests = state.walkRequests ?? []
            self.walkerEarnings = state.walkerEarnings ?? []
            self.vetAppointments = state.vetAppointments ?? []
            self.orders = state.orders ?? []
            self.brandOrders = state.brandOrders ?? []
            self.adoptionRequests = state.adoptionRequests ?? []
            self.shelterDonations = state.shelterDonations ?? []
            self.appNotifications = state.appNotifications ?? []
        } else {
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
                Story(id: "s1", dogName: "Тоби", ownerName: "Петър", photoURL: URL(string: "https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Първи плувен ден! 🌊", timestamp: Date().addingTimeInterval(-3600), isSeen: false, dogId: "nd1"),
                Story(id: "s2", dogName: "Мила", ownerName: "Ана", photoURL: URL(string: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Нов шампоан, нов живот 🧴", timestamp: Date().addingTimeInterval(-7200), isSeen: false, dogId: "nd2"),
                Story(id: "s3", dogName: "Локи", ownerName: "Марко", photoURL: URL(string: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Витоша днес 🏔", timestamp: Date().addingTimeInterval(-10800), isSeen: false, dogId: "nd3"),
                Story(id: "s4", dogName: "Чарли", ownerName: "Иван", photoURL: URL(string: "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=800&h=1200&q=85"), caption: "Снежен ден ❄️", timestamp: Date().addingTimeInterval(-14400), isSeen: false, dogId: "nd4"),
            ]

            save()
        }
    }

    // MARK: - Persistence

    func save() {
        let savedStatus: SavedDogStatus? = {
            guard let s = currentDogStatus else { return nil }
            return SavedDogStatus(dogId: s.dogId, statusId: s.statusId, setAt: s.setAt)
        }()

        let state = SavedState(
            dogs: dogs,
            vaccines: vaccines,
            weights: weights,
            grooming: grooming,
            vetVisits: vetVisits,
            medications: medications,
            lostDogAlerts: lostDogAlerts,
            diaryEntries: diaryEntries,
            milestones: milestones,
            myStories: myStories,
            userEvents: userEvents,
            stories: stories,
            currentDogStatus: savedStatus,
            walkerApplication: walkerApplication,
            registeredRoles: Array(registeredRoles),
            vetServices: vetServices,
            brandProducts: brandProducts,
            shelterAnimals: shelterAnimals,
            walkerPoints: walkerPoints,
            walkerWalksCount: walkerWalksCount,
            walkerReviews: walkerReviews,
            walkRequests: walkRequests,
            walkerEarnings: walkerEarnings,
            vetAppointments: vetAppointments,
            orders: orders,
            brandOrders: brandOrders,
            adoptionRequests: adoptionRequests,
            shelterDonations: shelterDonations,
            appNotifications: appNotifications,
            nextId: nextId
        )
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: Self.saveURL, options: .atomic)
        }
    }

    // MARK: - Dogs

    func addDog(_ dog: Dog) {
        dogs.append(dog)
        save()
    }

    func updateDog(_ dog: Dog) {
        if let i = dogs.firstIndex(where: { $0.id == dog.id }) {
            dogs[i] = dog
        }
        save()
    }

    func deleteDog(id: String) {
        dogs.removeAll { $0.id == id }
        vaccines.removeAll { $0.dogId == id }
        weights.removeAll { $0.dogId == id }
        grooming.removeAll { $0.dogId == id }
        vetVisits.removeAll { $0.dogId == id }
        medications.removeAll { $0.dogId == id }
        lostDogAlerts.removeAll { $0.dogId == id }
        save()
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
        save()
        scheduleVaccineNotifications()
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
        save()
    }

    // MARK: - Grooming

    func groomingFor(dogId: String) -> [GroomingLog] {
        grooming.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addGrooming(_ entry: GroomingLog) {
        grooming.append(entry)
        save()
    }

    // MARK: - Vet Visits

    func vetVisitsFor(dogId: String) -> [VetVisit] {
        vetVisits.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addVetVisit(_ visit: VetVisit) {
        vetVisits.append(visit)
        save()
    }

    // MARK: - Medications

    func medicationsFor(dogId: String) -> [Medication] {
        medications.filter { $0.dogId == dogId }.sorted { $0.startDate > $1.startDate }
    }

    func addMedication(_ med: Medication) {
        medications.append(med)
        save()
    }

    // MARK: - Diary Entries

    func diaryEntriesFor(dogId: String) -> [DiaryEntry] {
        diaryEntries.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.append(entry)
        save()
    }

    // MARK: - Milestones

    func milestonesFor(dogId: String) -> [Milestone] {
        milestones.filter { $0.dogId == dogId }.sorted { $0.date > $1.date }
    }

    func addMilestone(_ milestone: Milestone) {
        milestones.append(milestone)
        save()
    }

    // MARK: - Lost Dog Alerts

    func addLostDogAlert(_ alert: LostDogAlert) {
        lostDogAlerts.append(alert)
        save()
    }

    // MARK: - Events

    func addEvent(_ event: DogEvent) {
        userEvents.append(event)
        save()
    }

    // MARK: - Walker Application

    func submitWalkerApplication(_ application: WalkerApplication) {
        walkerApplication = application
        save()
    }

    func cancelWalkerApplication() {
        walkerApplication = nil
        save()
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

        let vaccines = vaccinesFor(dogId: dogId)
        let overdueCount = vaccines.filter { v in
            guard let due = v.nextDueDate else { return false }
            return due < now
        }.count
        let vaccineScore = max(0, 30 - (overdueCount * 10))
        let vaccineStatus = overdueCount == 0 ? "good" : overdueCount == 1 ? "warning" : "bad"
        results.append((category: "Ваксини", score: vaccineScore, maxScore: 30, status: vaccineStatus))

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
        let ranges: [String: (Double, Double)] = [
            "Лабрадор": (25.0, 36.0),
            "Френски булдог": (8.0, 14.0),
            "Голдън ретривър": (25.0, 34.0),
            "Бигъл": (9.0, 11.0),
            "Хъски": (16.0, 27.0),
            "Немска овчарка": (22.0, 40.0),
            "Йоркширски териер": (2.0, 3.5),
            "Чихуахуа": (1.5, 3.0),
            "Пудел": (18.0, 32.0),
            "Ротвайлер": (36.0, 60.0),
            "Такел": (7.0, 15.0),
            "Боксер": (25.0, 32.0),
            "Кокер шпаньол": (12.0, 16.0),
            "Шпиц": (1.8, 3.5),
            "Бордер коли": (14.0, 20.0),
            "Корги": (10.0, 14.0),
            "Мопс": (6.0, 8.0),
            "Далматинец": (24.0, 32.0),
            "Бултериер": (22.0, 38.0),
            "Акита": (32.0, 45.0),
        ]
        return ranges[breed] ?? (5.0, 40.0)
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

    func addStory(caption: String, photoURL: URL? = nil) {
        let story = Story(
            id: newId(),
            dogName: dogs.first?.name ?? "Рекс",
            ownerName: ownerName,
            photoURL: photoURL ?? dogs.first?.avatarURL,
            caption: caption,
            timestamp: Date(),
            isSeen: false
        )
        myStories.append(story)
        save()
    }

    func markStorySeen(id: String) {
        if let i = stories.firstIndex(where: { $0.id == id }) {
            stories[i].isSeen = true
        }
        save()
    }

    // MARK: - Dog Status

    func setDogStatus(dogId: String, statusId: String) {
        currentDogStatus = (dogId: dogId, statusId: statusId, setAt: Date())
        save()
    }

    func clearDogStatus() {
        currentDogStatus = nil
        save()
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleVaccineNotifications()
                }
            }
        }
    }

    func scheduleVaccineNotifications() {
        guard notificationSettings.vaccineReminders else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers:
            vaccines.map { "vaccine_\($0.id)" }
        )

        let now = Date()
        for vaccine in vaccines {
            guard let dueDate = vaccine.nextDueDate, dueDate > now else { continue }
            guard let dogName = dogs.first(where: { $0.id == vaccine.dogId })?.name else { continue }

            let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: dueDate) ?? dueDate
            guard reminderDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Напомняне за ваксина"
            content.body = "\(dogName) има нужда от \(vaccine.type.label) след 3 дни"
            content.sound = .default

            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: "vaccine_\(vaccine.id)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - Platform Roles

    func registerRole(_ role: UserRole) {
        registeredRoles.insert(role)
        switch role {
        case .vet: seedVetData()
        case .brand: seedBrandData()
        case .walker: seedWalkerData()
        case .shelter: seedShelterData()
        case .owner: break
        }
        save()
    }

    func addVetService(_ service: VetService) { vetServices.append(service); save() }
    func removeVetService(id: String) { vetServices.removeAll { $0.id == id }; save() }

    func addBrandProduct(_ product: BrandProduct) { brandProducts.append(product); save() }
    func removeBrandProduct(id: String) { brandProducts.removeAll { $0.id == id }; save() }

    func addShelterAnimal(_ animal: ShelterAnimal) { shelterAnimals.append(animal); save() }
    func removeShelterAnimal(id: String) { shelterAnimals.removeAll { $0.id == id }; save() }

    func addWalkerPoints(_ pts: Int) { walkerPoints += pts; save() }

    // MARK: - Walk Requests

    func submitWalkRequest(_ req: WalkRequest) {
        walkRequests.append(req)
        save()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            if let i = walkRequests.firstIndex(where: { $0.id == req.id }) {
                walkRequests[i].status = .accepted
                addNotification(icon: "figure.walk", title: "Заявка приета!", body: "\(req.walkerName) ще разходи \(req.dogName)", type: .walkOffer, actionId: req.id)
                save()
            }
        }
    }

    func submitWalkOffer(_ req: WalkRequest) {
        walkRequests.append(req)
        save()
        // Auto-accept after 3 seconds (simulating owner accepting)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if let i = walkRequests.firstIndex(where: { $0.id == req.id }) {
                walkRequests[i].status = .accepted
                save()
            }
        }
    }

    func completeWalk(id: String) {
        guard let i = walkRequests.firstIndex(where: { $0.id == id }) else { return }
        walkRequests[i].status = .completed
        let req = walkRequests[i]
        walkerEarnings.append(WalkerEarning(id: newId(), walkRequestId: req.id, clientName: ownerName, dogName: req.dogName, amount: req.price, status: .held, date: Date()))
        addNotification(icon: "checkmark.circle.fill", title: "Разходката приключи", body: "Разходката с \(req.dogName) приключи. Потвърди и остави ревю.", type: .walkComplete, actionId: req.id)
        save()
    }

    func confirmWalkDone(id: String) {
        guard let i = walkRequests.firstIndex(where: { $0.id == id }) else { return }
        walkRequests[i].status = .confirmed
        if let ei = walkerEarnings.firstIndex(where: { $0.walkRequestId == id }) {
            walkerEarnings[ei].status = .available
        }
        walkerPoints += 10
        walkerWalksCount += 1
        save()
    }

    func submitWalkReview(walkId: String, walkerId: String, rating: Int, comment: String) {
        let review = WalkerDashReview(id: newId(), clientName: ownerName, dogName: walkRequests.first(where: { $0.id == walkId })?.dogName ?? "", rating: rating, comment: comment, date: Date())
        walkerReviews.append(review)
        save()
    }

    func withdrawEarnings() {
        for i in walkerEarnings.indices where walkerEarnings[i].status == .available {
            walkerEarnings[i].status = .withdrawn
        }
        save()
    }

    // MARK: - Vet Appointments

    func submitVetAppointment(_ appt: VetAppointment) {
        vetAppointments.append(appt)
        let dateStr = appt.date.formatted(.dateTime.day().month(.abbreviated).hour().minute())
        addNotification(icon: "stethoscope", title: "Час запазен!", body: "Часът при \(appt.vetName) е запазен за \(dateStr)", type: .vetVisit, actionId: appt.id)
        save()
    }

    func completeVetAppointment(id: String, diagnosis: String?, prescription: String?) {
        if let i = vetAppointments.firstIndex(where: { $0.id == id }) {
            vetAppointments[i].status = .completed
            vetAppointments[i].diagnosis = diagnosis
            vetAppointments[i].prescription = prescription
            let dogName = vetAppointments[i].dogName
            addNotification(icon: "cross.case.fill", title: "Прегледът приключи", body: "Прегледът на \(dogName) приключи. Виж рецептата.", type: .vetVisit, actionId: id)
            save()
        }
    }

    func cancelVetAppointment(id: String) {
        if let i = vetAppointments.firstIndex(where: { $0.id == id }) {
            vetAppointments[i].status = .cancelled
        }
        save()
    }

    // MARK: - Orders

    // MARK: - Brand Orders

    func updateBrandOrderStatus(id: String, status: BrandOrderStatus) {
        if let i = brandOrders.firstIndex(where: { $0.id == id }) {
            brandOrders[i].status = status
            save()
        }
    }

    // MARK: - Adoption

    func approveAdoptionRequest(id: String) {
        if let i = adoptionRequests.firstIndex(where: { $0.id == id }) {
            adoptionRequests[i].status = .approved
            let animalName = adoptionRequests[i].animalName
            if let ai = shelterAnimals.firstIndex(where: { $0.id == adoptionRequests[i].animalId }) {
                shelterAnimals[ai].isAdopted = true
            }
            addNotification(icon: "heart.fill", title: "Осиновяване одобрено!", body: "Заявката за осиновяване на \(animalName) е одобрена!", type: .adoption, actionId: id)
            save()
        }
    }

    func rejectAdoptionRequest(id: String) {
        if let i = adoptionRequests.firstIndex(where: { $0.id == id }) {
            adoptionRequests[i].status = .rejected
            save()
        }
    }

    func addDonation(_ donation: Donation) { shelterDonations.append(donation); save() }

    // MARK: - App Notifications

    func addNotification(icon: String, title: String, body: String, type: AppNotification.NotifType, actionId: String? = nil) {
        let notif = AppNotification(id: newId(), icon: icon, title: title, body: body, type: type, isRead: false, actionId: actionId, createdAt: Date())
        appNotifications.insert(notif, at: 0)
        save()
    }

    func markNotificationRead(id: String) {
        if let i = appNotifications.firstIndex(where: { $0.id == id }) {
            appNotifications[i].isRead = true
            save()
        }
    }

    // MARK: - Orders

    func placeOrder(_ order: Order) {
        orders.append(order)
        addNotification(icon: "bag.fill", title: "Поръчка приета!", body: "Поръчка \(order.trackingNumber) е приета!", type: .order, actionId: order.id)
        save()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if let i = orders.firstIndex(where: { $0.id == order.id }) {
                orders[i].status = .shipped
                save()
            }
            try? await Task.sleep(for: .seconds(5))
            if let i = orders.firstIndex(where: { $0.id == order.id }) {
                orders[i].status = .delivered
                save()
            }
        }
    }
    func completeWalk() { walkerWalksCount += 1; walkerPoints += 10; save() }

    private func seedVetData() {
        guard vetServices.isEmpty else { return }
        let cal = Calendar.current
        vetAppointments = [
            VetAppointment(id: newId(), vetName: ownerName, clinicName: "Клиника Лапа", serviceName: "Първичен преглед", dogId: "1", dogName: "Рекс", date: cal.date(byAdding: .day, value: 1, to: Date())!, notes: "Годишен преглед", status: .upcoming, price: 50, createdAt: Date()),
            VetAppointment(id: newId(), vetName: ownerName, clinicName: "Клиника Лапа", serviceName: "Ваксинация (DHPPL)", dogId: "2", dogName: "Луна", date: cal.date(byAdding: .day, value: 2, to: Date())!, notes: "", status: .upcoming, price: 45, createdAt: Date()),
            VetAppointment(id: newId(), vetName: ownerName, clinicName: "Клиника Лапа", serviceName: "Почистване на зъби", dogId: "nd1", dogName: "Тоби", date: cal.date(byAdding: .day, value: -3, to: Date())!, notes: "Зъбен камък", status: .completed, price: 120, createdAt: Date().addingTimeInterval(-86400*5)),
            VetAppointment(id: newId(), vetName: ownerName, clinicName: "Клиника Лапа", serviceName: "Кръвна картина", dogId: "nd2", dogName: "Мила", date: cal.date(byAdding: .day, value: -7, to: Date())!, notes: "", status: .completed, price: 65, createdAt: Date().addingTimeInterval(-86400*10)),
            VetAppointment(id: newId(), vetName: ownerName, clinicName: "Клиника Лапа", serviceName: "Първичен преглед", dogId: "1", dogName: "Рекс", date: cal.date(byAdding: .day, value: -14, to: Date())!, notes: "Апатия", status: .completed, price: 50, createdAt: Date().addingTimeInterval(-86400*16)),
        ]
        vetServices = [
            VetService(id: newId(), name: "Първичен преглед", price: 50, duration: "30 мин", category: .exam),
            VetService(id: newId(), name: "Повторен преглед", price: 35, duration: "20 мин", category: .exam),
            VetService(id: newId(), name: "Ваксинация (DHPPL)", price: 45, duration: "15 мин", category: .vaccination),
            VetService(id: newId(), name: "Ваксинация (Бяс)", price: 40, duration: "15 мин", category: .vaccination),
            VetService(id: newId(), name: "Кастрация куче", price: 250, duration: "2 ч", category: .surgery),
            VetService(id: newId(), name: "Почистване на зъбен камък", price: 120, duration: "1 ч", category: .dental),
            VetService(id: newId(), name: "Кръвна картина", price: 65, duration: "30 мин", category: .lab),
            VetService(id: newId(), name: "Баня + сушене", price: 40, duration: "1 ч", category: .grooming),
        ]
    }

    private func seedBrandData() {
        guard brandProducts.isEmpty else { return }
        let cal = Calendar.current
        brandOrders = [
            BrandOrder(id: newId(), productId: "bp1", productName: "Premium Adult Храна 12кг", buyerName: "Мария К.", quantity: 1, totalPrice: 89.90, status: .delivered, orderedAt: cal.date(byAdding: .day, value: -5, to: Date())!),
            BrandOrder(id: newId(), productId: "bp2", productName: "Дентални лакомства x10", buyerName: "Георги П.", quantity: 2, totalPrice: 37.00, status: .shipped, orderedAt: cal.date(byAdding: .day, value: -2, to: Date())!),
            BrandOrder(id: newId(), productId: "bp1", productName: "Premium Adult Храна 12кг", buyerName: "Иван С.", quantity: 1, totalPrice: 89.90, status: .processing, orderedAt: cal.date(byAdding: .day, value: -1, to: Date())!),
            BrandOrder(id: newId(), productId: "bp5", productName: "Шампоан за къса козина", buyerName: "Ана Д.", quantity: 1, totalPrice: 15.90, status: .new, orderedAt: Date()),
        ]
        brandProducts = [
            BrandProduct(id: newId(), name: "Premium Adult Храна 12кг", price: 89.90, category: "Храна", status: .approved, submittedAt: cal.date(byAdding: .day, value: -14, to: Date())!),
            BrandProduct(id: newId(), name: "Дентални лакомства x10", price: 18.50, category: "Здраве", status: .approved, submittedAt: cal.date(byAdding: .day, value: -10, to: Date())!),
            BrandProduct(id: newId(), name: "Интерактивна топка", price: 24.90, category: "Играчки", status: .pending, submittedAt: cal.date(byAdding: .day, value: -2, to: Date())!),
            BrandProduct(id: newId(), name: "Зимно яке M", price: 59.90, category: "Аксесоари", status: .rejected, submittedAt: cal.date(byAdding: .day, value: -7, to: Date())!),
            BrandProduct(id: newId(), name: "Шампоан за къса козина", price: 15.90, category: "Грижа", status: .approved, submittedAt: cal.date(byAdding: .day, value: -20, to: Date())!),
        ]
    }

    private func seedWalkerData() {
        guard walkerReviews.isEmpty else { return }
        walkerPoints = 185
        walkerWalksCount = 14
        let cal = Calendar.current
        walkerReviews = [
            WalkerDashReview(id: newId(), clientName: "Мария К.", dogName: "Бъди", rating: 5, comment: "Перфектна разходка, Бъди беше щастлив!", date: cal.date(byAdding: .day, value: -1, to: Date())!),
            WalkerDashReview(id: newId(), clientName: "Иван П.", dogName: "Лора", rating: 4, comment: "Много внимателен, ще ползваме пак.", date: cal.date(byAdding: .day, value: -3, to: Date())!),
            WalkerDashReview(id: newId(), clientName: "Десислава М.", dogName: "Чарли", rating: 5, comment: "Чарли го обожава! Винаги щастлив след разходка.", date: cal.date(byAdding: .day, value: -5, to: Date())!),
            WalkerDashReview(id: newId(), clientName: "Георги Т.", dogName: "Рокси", rating: 5, comment: "Препоръчвам! Надежден и точен.", date: cal.date(byAdding: .day, value: -8, to: Date())!),
            WalkerDashReview(id: newId(), clientName: "Елена В.", dogName: "Макс", rating: 4, comment: "Добра разходка, малко късно се върна.", date: cal.date(byAdding: .day, value: -12, to: Date())!),
        ]
    }

    private func seedShelterData() {
        guard shelterAnimals.isEmpty else { return }
        let cal = Calendar.current
        adoptionRequests = [
            AdoptionRequest(id: newId(), animalId: "sa1", animalName: "Шаро", requesterName: "Мария Иванова", requesterPhone: "+359 88 111 2222", requesterNote: "Имаме голям двор, обичаме кучета!", status: .pending, submittedAt: Date().addingTimeInterval(-3600)),
            AdoptionRequest(id: newId(), animalId: "sa3", animalName: "Бела", requesterName: "Петър Георгиев", requesterPhone: "+359 89 333 4444", requesterNote: "Имаме две деца, търсим игриво куче.", status: .pending, submittedAt: Date().addingTimeInterval(-7200)),
            AdoptionRequest(id: newId(), animalId: "sa4", animalName: "Рокси", requesterName: "Десислава М.", requesterPhone: "+359 87 555 6666", requesterNote: "", status: .approved, submittedAt: Date().addingTimeInterval(-86400*3)),
        ]
        shelterDonations = [
            Donation(id: newId(), donorName: "Мария К.", amount: 20, isRecurring: true, date: cal.date(byAdding: .day, value: -1, to: Date())!),
            Donation(id: newId(), donorName: "Анонимен", amount: 50, isRecurring: false, date: cal.date(byAdding: .day, value: -3, to: Date())!),
            Donation(id: newId(), donorName: "Георги Т.", amount: 10, isRecurring: true, date: cal.date(byAdding: .day, value: -5, to: Date())!),
            Donation(id: newId(), donorName: "Елена В.", amount: 5, isRecurring: true, date: cal.date(byAdding: .day, value: -7, to: Date())!),
            Donation(id: newId(), donorName: "ООД Зоовита", amount: 200, isRecurring: false, date: cal.date(byAdding: .day, value: -10, to: Date())!),
            Donation(id: newId(), donorName: "Иван П.", amount: 15, isRecurring: true, date: cal.date(byAdding: .day, value: -12, to: Date())!),
        ]
        shelterAnimals = [
            ShelterAnimal(id: newId(), name: "Шаро", breed: "Микс", age: "3 години", sex: .male, description: "Игрив и приятелски настроен.", photoURL: URL(string: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&h=400&q=85"), isAdopted: false, addedAt: Date().addingTimeInterval(-86400*10)),
            ShelterAnimal(id: newId(), name: "Мечо", breed: "Немска овчарка", age: "5 години", sex: .male, description: "Тих и послушен. Обича разходки.", photoURL: URL(string: "https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?auto=format&fit=crop&w=400&h=400&q=85"), isAdopted: false, addedAt: Date().addingTimeInterval(-86400*7)),
            ShelterAnimal(id: newId(), name: "Бела", breed: "Лабрадор микс", age: "1 година", sex: .female, description: "Енергична, обича деца.", photoURL: URL(string: "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?auto=format&fit=crop&w=400&h=400&q=85"), isAdopted: false, addedAt: Date().addingTimeInterval(-86400*5)),
            ShelterAnimal(id: newId(), name: "Рокси", breed: "Микс", age: "2 години", sex: .female, description: "Намерена на улицата, вече ваксинирана.", photoURL: URL(string: "https://images.unsplash.com/photo-1561037404-61cd46aa615b?auto=format&fit=crop&w=400&h=400&q=85"), isAdopted: true, addedAt: Date().addingTimeInterval(-86400*20)),
            ShelterAnimal(id: newId(), name: "Тарзан", breed: "Питбул", age: "4 години", sex: .male, description: "Кротък гигант. Обожава хората.", photoURL: URL(string: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=400&h=400&q=85"), isAdopted: false, addedAt: Date().addingTimeInterval(-86400*3)),
        ]
    }

    // MARK: - ID generation

    func newId() -> String {
        nextId += 1
        return String(nextId)
    }
}
