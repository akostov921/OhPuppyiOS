import SwiftUI

// MARK: - Breed Data

struct BreedInfo {
    let name: String
    let weightRange: String
    let lifeExpectancy: String
    let energyLevel: Double // 0.0 - 1.0
    let energyLabel: String
    let sizeCategory: String
    let description: String
    let exerciseMinutes: String
    let exerciseTips: String
    let dailyCalories: String
    let mealFrequency: String
    let foodTips: String
    let healthIssues: [(icon: String, name: String, description: String)]
    let temperament: [String]
    let coatShedding: String
    let coatFrequency: String
    let coatTips: String
}

private let breedDatabase: [String: BreedInfo] = [
    "Лабрадор": BreedInfo(
        name: "Лабрадор",
        weightRange: "25-36 кг",
        lifeExpectancy: "10-14 г.",
        energyLevel: 0.85,
        energyLabel: "Висока",
        sizeCategory: "Голяма",
        description: "Лабрадорът е една от най-популярните породи в света. Приятелски, интелигентен и лоялен.",
        exerciseMinutes: "60-80 мин/ден",
        exerciseTips: "Обича плуване и игра на донеси. Идеален за активни семейства.",
        dailyCalories: "1500-2000 kcal",
        mealFrequency: "2 пъти дневно",
        foodTips: "Склонен към напълняване. Контролирай порциите и избягвай прекалено лакомства.",
        healthIssues: [
            ("figure.walk", "Дисплазия на тазобедрената става", "Чести проблеми със ставите, особено при по-възрастни кучета"),
            ("figure.walk", "Дисплазия на лакътя", "Наследствено заболяване, причиняващо куцане"),
            ("scalemass.fill", "Затлъстяване", "Лабрадорите са склонни към напълняване без контрол"),
            ("eye.fill", "Очни проблеми (PRA)", "Прогресивна атрофия на ретината може да доведе до слепота"),
        ],
        temperament: ["Приятелски", "Интелигентен", "Обича вода", "Лоялен", "Активен"],
        coatShedding: "Умерена",
        coatFrequency: "Четкай 2 пъти/седмица",
        coatTips: "Водоустойчива двойна козина. Редовното четкане намалява козината по мебелите."
    ),
    "Френски булдог": BreedInfo(
        name: "Френски булдог",
        weightRange: "8-14 кг",
        lifeExpectancy: "10-12 г.",
        energyLevel: 0.4,
        energyLabel: "Ниска-Средна",
        sizeCategory: "Малка",
        description: "Френският булдог е компактен, мускулест и с уникален характер. Перфектен за апартамент.",
        exerciseMinutes: "30 мин/ден",
        exerciseTips: "Избягвай горещо време. Кратки разходки сутрин и вечер са идеални.",
        dailyCalories: "700-900 kcal",
        mealFrequency: "2 пъти дневно",
        foodTips: "Хипоалергенна храна е препоръчителна. Внимавай с газове от определени храни.",
        healthIssues: [
            ("lungs.fill", "Брахицефален синдром", "Затруднено дишане поради плоското лице"),
            ("hand.raised.fill", "Кожни алергии", "Чести дерматити, особено в гънките на кожата"),
            ("figure.walk", "Проблеми с гръбнака", "Склонност към дискова херния"),
            ("thermometer.high", "Прегряване", "Не понасят високи температури добре"),
        ],
        temperament: ["Игрив", "Упорит", "Привързан", "Спокоен", "Адаптивен"],
        coatShedding: "Ниска",
        coatFrequency: "Минимална грижа",
        coatTips: "Почиствай гънките на лицето всяка седмица. Къса козина, не изисква честа баня."
    ),
    "Голдън ретривър": BreedInfo(
        name: "Голдън ретривър",
        weightRange: "25-34 кг",
        lifeExpectancy: "10-12 г.",
        energyLevel: 0.8,
        energyLabel: "Висока",
        sizeCategory: "Голяма",
        description: "Голдън ретривърът е нежен, интелигентен и отдаден компаньон. Чудесен за семейства.",
        exerciseMinutes: "60 мин/ден",
        exerciseTips: "Обича да носи предмети и да плува. Нуждае се от ежедневна активна разходка.",
        dailyCalories: "1400-1800 kcal",
        mealFrequency: "2 пъти дневно",
        foodTips: "Балансирана диета с достатъчно протеин за поддържане на козината.",
        healthIssues: [
            ("heart.fill", "Риск от рак", "По-висока честота на онкологични заболявания"),
            ("figure.walk", "Дисплазия на тазобедрената/лакътната става", "Наследствена склонност към ставни проблеми"),
            ("heart.fill", "Сърдечни заболявания", "Субаортна стеноза е по-честа при породата"),
            ("ear.fill", "Ушни инфекции", "Висящите уши задържат влага и бактерии"),
        ],
        temperament: ["Нежен", "Интелигентен", "Търпелив", "Обича деца", "Послушен"],
        coatShedding: "Висока",
        coatFrequency: "Четкай ежедневно",
        coatTips: "Гъста двойна козина изисква редовен професионален гриминг. Линее обилно."
    ),
]

private let fallbackBreed = BreedInfo(
    name: "Смесена порода",
    weightRange: "5-40 кг",
    lifeExpectancy: "10-15 г.",
    energyLevel: 0.6,
    energyLabel: "Средна",
    sizeCategory: "Различна",
    description: "Смесените породи са уникални и често по-здрави от чистокръвните. Всяко куче е специално.",
    exerciseMinutes: "45-60 мин/ден",
    exerciseTips: "Адаптирай разходките спрямо размера и възрастта на кучето.",
    dailyCalories: "800-1500 kcal",
    mealFrequency: "2 пъти дневно",
    foodTips: "Висококачествена храна, подходяща за размера. Консултирай се с ветеринар.",
    healthIssues: [
        ("heart.fill", "Общо здраве", "Смесените породи обикновено имат по-малко генетични проблеми"),
        ("scalemass.fill", "Контрол на тегло", "Поддържай здравословно тегло за дълъг живот"),
        ("cross.vial.fill", "Редовни прегледи", "Годишен ветеринарен преглед е задължителен"),
    ],
    temperament: ["Уникален", "Адаптивен", "Верен", "Любопитен"],
    coatShedding: "Различна",
    coatFrequency: "Зависи от козината",
    coatTips: "Грижата зависи от типа козина. Редовно четкане е препоръчително за всички."
)

// MARK: - BreedInfoView

struct BreedInfoView: View {
    let breed: String
    let dogAvatarURL: URL?
    @Environment(AppStore.self) private var store

    private var info: BreedInfo {
        breedDatabase[breed] ?? fallbackBreed
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                heroSection
                quickStats
                descriptionSection
                exerciseSection
                feedingSection
                healthIssuesSection
                temperamentSection
                coatSection
            }
            .padding(.bottom, 60)
        }
        .background(OPTheme.bg)
        .navigationTitle("За породата")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            AsyncImage(url: dogAvatarURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(OPTheme.surfaceSunken)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(OPTheme.mint)
                        }
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(Circle())
            .overlay(Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 3))

            Text(info.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(OPTheme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        HStack(spacing: 8) {
            quickStatCard(icon: "scalemass.fill", label: "Тегло", value: info.weightRange)
            quickStatCard(icon: "heart.fill", label: "Живот", value: info.lifeExpectancy)
            quickStatCard(icon: "bolt.fill", label: "Енергия", value: info.energyLabel)
            quickStatCard(icon: "ruler.fill", label: "Размер", value: info.sizeCategory)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func quickStatCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(OPTheme.mint)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(OPTheme.textTertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(OPTheme.text)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Description

    private var descriptionSection: some View {
        sectionCard(title: "Описание", icon: "text.book.closed.fill") {
            Text(info.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Exercise

    private var exerciseSection: some View {
        sectionCard(title: "Нужди от движение", icon: "figure.run") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text(info.exerciseMinutes)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(OPTheme.primary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(OPTheme.surfaceSunken)
                                .frame(height: 8)
                            Capsule()
                                .fill(OPTheme.mintGradient)
                                .frame(width: geo.size.width * info.energyLevel, height: 8)
                        }
                    }
                    .frame(height: 8)
                }

                Text(info.exerciseTips)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Feeding

    private var feedingSection: some View {
        sectionCard(title: "Хранене", icon: "fork.knife") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 16) {
                    feedingStat(label: "Калории", value: info.dailyCalories)
                    feedingStat(label: "Хранения", value: info.mealFrequency)
                }

                Text(info.foodTips)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
    }

    private func feedingStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(OPTheme.textTertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(OPTheme.text)
        }
    }

    // MARK: - Health Issues

    private var healthIssuesSection: some View {
        sectionCard(title: "Чести здравни проблеми", icon: "cross.case.fill") {
            VStack(spacing: 10) {
                ForEach(Array(info.healthIssues.enumerated()), id: \.offset) { _, issue in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: issue.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(OPTheme.rose)
                            .frame(width: 28, height: 28)
                            .background(OPTheme.roseSoft, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(issue.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                            Text(issue.description)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                                .lineSpacing(2)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Temperament

    private var temperamentSection: some View {
        sectionCard(title: "Темперамент", icon: "sparkles") {
            FlowLayout(spacing: 8) {
                ForEach(info.temperament, id: \.self) { trait in
                    Text(trait)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OPTheme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(OPTheme.primarySoft, in: Capsule())
                }
            }
        }
    }

    // MARK: - Coat

    private var coatSection: some View {
        sectionCard(title: "Грижа за козината", icon: "comb.fill") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 16) {
                    coatStat(label: "Линеене", value: info.coatShedding)
                    coatStat(label: "Честота", value: info.coatFrequency)
                }

                Text(info.coatTips)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
    }

    private func coatStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(OPTheme.textTertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(OPTheme.text)
        }
    }

    // MARK: - Section Card Helper

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.mint)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, OPTheme.screenPadding)
    }
}
