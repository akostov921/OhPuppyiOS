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
