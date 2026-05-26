import Foundation
import SwiftUI

struct Dog: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var breed: String
    var birthDate: Date
    var sex: Sex
    var neutered: Bool
    var weight: Double
    var microchip: String?
    var bio: String?
    var avatarURL: URL?
    let ownerId: String

    enum Sex: String, CaseIterable, Codable {
        case male, female
        var label: String {
            switch self {
            case .male: "♂ Мъжки"
            case .female: "♀ Женски"
            }
        }
        var icon: String {
            self == .male ? "♂" : "♀"
        }
    }

    var age: String {
        let months = Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
        if months >= 12 {
            let years = months / 12
            return "\(years) г."
        }
        return "\(months) м."
    }

    var ageDescription: String {
        let comps = Calendar.current.dateComponents([.year, .month], from: birthDate, to: .now)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        if y == 0 { return "\(m) месеца на чисто щастие" }
        if m == 0 { return "\(y) \(y == 1 ? "година" : "години") на чисто щастие" }
        return "\(y) \(y == 1 ? "година" : "години") и \(m) \(m == 1 ? "месец" : "месеца") на чисто щастие"
    }
}

struct Vaccine: Identifiable, Codable {
    let id: String
    let dogId: String
    var type: VaccineType
    var dateAdministered: Date
    var nextDueDate: Date?
    var vet: String?
    var clinic: String?
    var notes: String?
    var verificationCode: String?
    var verifiedByVet: String?
    var isVerified: Bool { verificationCode != nil }
}

enum HomeSection: String, CaseIterable, Codable {
    case stories, upcomingEvents, todayStats, social, playdate, health

    var label: String {
        switch self {
        case .stories: "Сторита"
        case .upcomingEvents: "Предстоящи"
        case .todayStats: "Днес"
        case .social: "Социално"
        case .playdate: "Playdate"
        case .health: "Здраве"
        }
    }

    var icon: String {
        switch self {
        case .stories: "circle.circle.fill"
        case .upcomingEvents: "calendar"
        case .todayStats: "chart.bar.fill"
        case .social: "photo.on.rectangle"
        case .playdate: "heart.fill"
        case .health: "cross.case.fill"
        }
    }
}

enum UserRole: String, CaseIterable, Codable {
    case owner, vet, brand, walker, shelter
    var label: String {
        switch self {
        case .owner: "Собственик"
        case .vet: "Ветеринар"
        case .brand: "Бранд"
        case .walker: "Разходчик"
        case .shelter: "Приют"
        }
    }
    var icon: String {
        switch self {
        case .owner: "house.fill"
        case .vet: "stethoscope"
        case .brand: "bag.fill"
        case .walker: "figure.walk"
        case .shelter: "building.2.fill"
        }
    }
}

enum VaccineType: String, CaseIterable, Identifiable, Codable {
    case rabies, dhppl, bordetella, deworming, externalParasites, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .rabies: "Бяс (Rabies)"
        case .dhppl: "DHPPL"
        case .bordetella: "Bordetella"
        case .deworming: "Обезпаразитяване"
        case .externalParasites: "Бълхи/кърлежи"
        case .other: "Друго"
        }
    }

    var defaultIntervalMonths: Int {
        switch self {
        case .rabies, .dhppl: 12
        case .bordetella: 6
        case .deworming: 3
        case .externalParasites: 1
        case .other: 12
        }
    }
}

struct WeightLog: Identifiable, Codable {
    let id: String
    let dogId: String
    var weight: Double
    var date: Date
    var notes: String?
}

struct GroomingLog: Identifiable, Codable {
    let id: String
    let dogId: String
    var type: GroomType
    var date: Date
    var groomer: String?
    var price: Double?
    var notes: String?

    enum GroomType: String, CaseIterable, Codable {
        case bath, haircut, nails, teeth, ears
        var label: String {
            switch self {
            case .bath: "Баня"
            case .haircut: "Подстригване"
            case .nails: "Нокти"
            case .teeth: "Зъби"
            case .ears: "Уши"
            }
        }
        var icon: String {
            switch self {
            case .bath: "drop.fill"
            case .haircut: "scissors"
            case .nails: "hand.raised.fill"
            case .teeth: "mouth.fill"
            case .ears: "ear.fill"
            }
        }
    }
}

// MARK: - Vet Visit

struct VetVisit: Identifiable, Codable {
    let id: String
    let dogId: String
    var date: Date
    var reason: String
    var diagnosis: String?
    var vet: String?
    var clinic: String?
    var price: Double?
    var notes: String?
}

// MARK: - Medication

enum MedFrequency: String, CaseIterable, Codable {
    case daily, twiceDaily, weekly, monthly, asNeeded
    var label: String {
        switch self {
        case .daily: "Веднъж дневно"
        case .twiceDaily: "2 пъти дневно"
        case .weekly: "Веднъж седмично"
        case .monthly: "Веднъж месечно"
        case .asNeeded: "При нужда"
        }
    }
}

struct Medication: Identifiable, Codable {
    let id: String
    let dogId: String
    var name: String
    var dose: String
    var frequency: MedFrequency
    var startDate: Date
    var endDate: Date?
    var notes: String?

    var isActive: Bool {
        if let end = endDate { return end >= Date() }
        return true
    }
}

// MARK: - Diary Entry

struct DiaryEntry: Identifiable, Codable {
    let id: String
    let dogId: String
    var text: String
    var date: Date
    var photoURL: URL?
}

// MARK: - Milestone

struct Milestone: Identifiable, Codable {
    let id: String
    let dogId: String
    var emoji: String
    var title: String
    var date: Date
    var notes: String?
    var isCustom: Bool
}

// MARK: - Story

struct Story: Identifiable, Codable {
    let id: String
    let dogName: String
    let ownerName: String
    let photoURL: URL?
    let caption: String
    let timestamp: Date
    var isSeen: Bool
    var dogId: String?
}

// MARK: - Dog Status

struct DogStatus: Identifiable {
    let id: String
    let emoji: String
    let label: String
    let color: Color
}

// MARK: - Lost Dog Alert

struct LostDogAlert: Identifiable, Codable {
    let id: String
    let dogId: String
    var lastSeenTime: Date
    var lastSeenPlace: String
    var description: String
    var contactPhone: String
    var isResolved: Bool
}

// MARK: - Walker Application

struct WalkerApplication: Identifiable, Codable {
    let id: String
    var name: String
    var phone: String
    var bio: String
    var services: [ServiceType]
    var pricePerWalk: Double
    var idPhotoURL: URL?
    var status: Status
    var submittedAt: Date

    enum Status: String, Codable {
        case pending, approved, rejected

        var label: String {
            switch self {
            case .pending: "В изчакване"
            case .approved: "Одобрен"
            case .rejected: "Отхвърлен"
            }
        }
    }

    enum ServiceType: String, CaseIterable, Codable {
        case walking, sitting, training

        var label: String {
            switch self {
            case .walking: "Разходка"
            case .sitting: "Гледане"
            case .training: "Тренировка"
            }
        }

        var icon: String {
            switch self {
            case .walking: "figure.walk"
            case .sitting: "house.fill"
            case .training: "graduationcap.fill"
            }
        }
    }
}

// MARK: - Platform Business Models

enum ApprovalStatus: String, CaseIterable, Codable {
    case pending, approved, rejected
    var label: String {
        switch self {
        case .pending: "В изчакване"
        case .approved: "Одобрен"
        case .rejected: "Отхвърлен"
        }
    }
}

struct VetService: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var price: Double
    var duration: String
    var category: VetServiceCategory
}

enum VetServiceCategory: String, CaseIterable, Codable {
    case exam, vaccination, surgery, dental, grooming, lab
    var label: String {
        switch self {
        case .exam: "Преглед"
        case .vaccination: "Ваксинация"
        case .surgery: "Хирургия"
        case .dental: "Зъболечение"
        case .grooming: "Грижа"
        case .lab: "Лаборатория"
        }
    }
    var icon: String {
        switch self {
        case .exam: "stethoscope"
        case .vaccination: "syringe.fill"
        case .surgery: "scissors"
        case .dental: "mouth.fill"
        case .grooming: "sparkles"
        case .lab: "testtube.2"
        }
    }
}

struct BrandProduct: Identifiable, Codable {
    let id: String
    var name: String
    var price: Double
    var category: String
    var status: ApprovalStatus
    var submittedAt: Date
}

struct ShelterAnimal: Identifiable, Codable {
    let id: String
    var name: String
    var breed: String
    var age: String
    var sex: Dog.Sex
    var description: String
    var photoURL: URL?
    var isAdopted: Bool
    var addedAt: Date
}

struct WalkerDashReview: Identifiable, Codable {
    let id: String
    var clientName: String
    var dogName: String
    var rating: Int
    var comment: String
    var date: Date
}

enum WalkerBadge: String, CaseIterable, Codable {
    case newcomer, reliable, popular, expert, legend
    var label: String {
        switch self {
        case .newcomer: "Начинаещ"
        case .reliable: "Надежден"
        case .popular: "Популярен"
        case .expert: "Експерт"
        case .legend: "Легенда"
        }
    }
    var icon: String {
        switch self {
        case .newcomer: "leaf.fill"
        case .reliable: "hand.thumbsup.fill"
        case .popular: "star.fill"
        case .expert: "crown.fill"
        case .legend: "trophy.fill"
        }
    }
    var minPoints: Int {
        switch self {
        case .newcomer: 0
        case .reliable: 100
        case .popular: 300
        case .expert: 750
        case .legend: 1500
        }
    }
}

// MARK: - Walk Request

enum WalkStatus: String, Codable {
    case pending, accepted, inProgress, completed, confirmed
    var label: String {
        switch self {
        case .pending: "Изчакване"
        case .accepted: "Приета"
        case .inProgress: "В ход"
        case .completed: "Завършена"
        case .confirmed: "Потвърдена"
        }
    }
}

struct WalkRequest: Identifiable, Codable, Hashable {
    let id: String
    var walkerId: String
    var walkerName: String
    var walkerPhotoURL: String?
    var walkerBadge: WalkerBadge
    var dogId: String
    var dogName: String
    var date: Date
    var duration: Int
    var note: String
    var price: Double
    var status: WalkStatus
    var createdAt: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WalkRequest, rhs: WalkRequest) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Vet Appointment

enum AppointmentStatus: String, Codable {
    case upcoming, completed, cancelled
    var label: String {
        switch self {
        case .upcoming: "Предстоящ"
        case .completed: "Завършен"
        case .cancelled: "Отменен"
        }
    }
}

struct VetAppointment: Identifiable, Codable {
    let id: String
    var vetName: String
    var clinicName: String
    var serviceName: String
    var dogId: String
    var dogName: String
    var date: Date
    var notes: String
    var status: AppointmentStatus
    var price: Double
    var createdAt: Date
    var prescription: String?
    var diagnosis: String?
}

// MARK: - Order

enum OrderStatus: String, Codable {
    case processing, shipped, delivered
    var label: String {
        switch self {
        case .processing: "Обработва се"
        case .shipped: "Изпратена"
        case .delivered: "Доставена"
        }
    }
}

struct Order: Identifiable, Codable {
    let id: String
    var productName: String
    var brandName: String
    var price: Double
    var date: Date
    var status: OrderStatus
    var trackingNumber: String
    var photoURL: String
}

// MARK: - Walker Earning

enum EarningStatus: String, Codable {
    case held, available, withdrawn
    var label: String {
        switch self {
        case .held: "Задържана"
        case .available: "Налична"
        case .withdrawn: "Изтеглена"
        }
    }
}

struct WalkerEarning: Identifiable, Codable {
    let id: String
    var walkRequestId: String
    var clientName: String
    var dogName: String
    var amount: Double
    var status: EarningStatus
    var date: Date
}

// MARK: - Brand Order

enum BrandOrderStatus: String, CaseIterable, Codable {
    case new, processing, shipped, delivered
    var label: String {
        switch self {
        case .new: "Нова"
        case .processing: "Обработва се"
        case .shipped: "Изпратена"
        case .delivered: "Доставена"
        }
    }
}

struct BrandOrder: Identifiable, Codable {
    let id: String
    var productId: String
    var productName: String
    var buyerName: String
    var quantity: Int
    var totalPrice: Double
    var status: BrandOrderStatus
    var orderedAt: Date
}

// MARK: - Adoption Request

enum AdoptionRequestStatus: String, CaseIterable, Codable {
    case pending, approved, rejected
    var label: String {
        switch self {
        case .pending: "В изчакване"
        case .approved: "Одобрена"
        case .rejected: "Отказана"
        }
    }
}

struct AdoptionRequest: Identifiable, Codable {
    let id: String
    var animalId: String
    var animalName: String
    var requesterName: String
    var requesterPhone: String
    var requesterNote: String
    var status: AdoptionRequestStatus
    var submittedAt: Date
}

// MARK: - Donation

struct Donation: Identifiable, Codable {
    let id: String
    var donorName: String
    var amount: Double
    var isRecurring: Bool
    var date: Date
    var note: String?
}

// MARK: - App Notification

struct AppNotification: Identifiable, Codable {
    let id: String
    var icon: String
    var title: String
    var body: String
    var type: NotifType
    var isRead: Bool
    var actionId: String?
    var createdAt: Date

    enum NotifType: String, Codable {
        case vaccine, vetVisit, walkComplete, walkOffer, adoption, order, social
    }
}
