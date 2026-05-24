import SwiftUI

// MARK: - Product Recommendation Model

struct ProductRecommendation: Identifiable {
    let id: String
    let name: String
    let price: Int
    let rating: Double
    let category: String
    let imageColor: Color
    let imageIcon: String
}

// MARK: - Breed Health Tip

struct BreedHealthTip: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let severity: TipSeverity

    enum TipSeverity {
        case info, warning, important
        var color: Color {
            switch self {
            case .info: OPTheme.sky
            case .warning: OPTheme.accent
            case .important: OPTheme.rose
            }
        }
        var bgColor: Color {
            switch self {
            case .info: OPTheme.skySoft
            case .warning: OPTheme.accentSoft
            case .important: OPTheme.roseSoft
            }
        }
    }
}

// MARK: - Breed Recommendations View

struct BreedRecommendationsView: View {
    let breed: String
    @State private var showPurchaseAlert = false
    @State private var selectedProduct: ProductRecommendation?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header
                header
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                // Food section
                sectionView(title: "Храна", icon: "fork.knife", color: OPTheme.accent, products: foodProducts)
                    .padding(.bottom, 24)

                // Toys section
                sectionView(title: "Играчки", icon: "gamecontroller.fill", color: OPTheme.mint, products: toyProducts)
                    .padding(.bottom, 24)

                // Grooming section
                sectionView(title: "Грижа", icon: "sparkles", color: OPTheme.sky, products: groomingProducts)
                    .padding(.bottom, 24)

                // Health tips
                healthSection
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Пренасочване към магазина...", isPresented: $showPurchaseAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let product = selectedProduct {
                Text("Ще бъдеш пренасочен(а) към магазина за \(product.name).")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            // Dog avatar placeholder
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(OPTheme.primaryGradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("Препоръки за")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                Text(breed)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            Spacer()
        }
    }

    // MARK: - Section View

    private func sectionView(title: String, icon: String, color: Color, products: [ProductRecommendation]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }
            .padding(.horizontal, OPTheme.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(products) { product in
                        productCard(product)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Product Card

    private func productCard(_ product: ProductRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Product image placeholder
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(product.imageColor.opacity(0.12))
                .frame(width: 160, height: 120)
                .overlay {
                    Image(systemName: product.imageIcon)
                        .font(.system(size: 36))
                        .foregroundStyle(product.imageColor)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(OPTheme.accent)
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                }

                // Breed badge
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                    Text("Подходящо за \(breed)")
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundStyle(OPTheme.mint)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(OPTheme.mintSoft, in: Capsule())

                HStack {
                    Text("\(product.price) лв")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.primary)

                    Spacer()

                    Button {
                        selectedProduct = product
                        showPurchaseAlert = true
                    } label: {
                        Text("Купи")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(OPTheme.mintGradient, in: Capsule())
                    }
                }
            }
            .padding(10)
        }
        .frame(width: 160)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 6, y: 3)
    }

    // MARK: - Health Section

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.clipboard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(OPTheme.rose)
                Text("Здраве")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            ForEach(healthTips) { tip in
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tip.severity.bgColor)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: tip.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(tip.severity.color)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tip.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text(tip.description)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(OPTheme.textSecondary)
                            .lineSpacing(2)
                    }
                }
                .padding(14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(OPTheme.border, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Data

    private var foodProducts: [ProductRecommendation] {
        switch breed {
        case "Лабрадор":
            return [
                ProductRecommendation(id: "f1", name: "Royal Canin Labrador", price: 89, rating: 4.8, category: "Храна", imageColor: OPTheme.accent, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f2", name: "Hill's Science Diet Large", price: 75, rating: 4.6, category: "Храна", imageColor: OPTheme.mint, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f3", name: "Brit Care Weight Control", price: 65, rating: 4.5, category: "Храна", imageColor: OPTheme.sky, imageIcon: "leaf.fill"),
            ]
        case "Френски булдог":
            return [
                ProductRecommendation(id: "f1", name: "Royal Canin French Bulldog", price: 79, rating: 4.7, category: "Храна", imageColor: OPTheme.accent, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f2", name: "Acana Singles Duck", price: 95, rating: 4.8, category: "Храна", imageColor: OPTheme.mint, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f3", name: "Orijen Small Breed", price: 105, rating: 4.9, category: "Храна", imageColor: OPTheme.sky, imageIcon: "leaf.fill"),
            ]
        case "Голдън ретривър":
            return [
                ProductRecommendation(id: "f1", name: "Royal Canin Golden Retriever", price: 85, rating: 4.7, category: "Храна", imageColor: OPTheme.accent, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f2", name: "Pro Plan Large Athletic", price: 72, rating: 4.5, category: "Храна", imageColor: OPTheme.mint, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f3", name: "Eukanuba Large Breed", price: 68, rating: 4.4, category: "Храна", imageColor: OPTheme.sky, imageIcon: "leaf.fill"),
            ]
        default:
            return [
                ProductRecommendation(id: "f1", name: "Royal Canin Adult", price: 75, rating: 4.6, category: "Храна", imageColor: OPTheme.accent, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f2", name: "Hill's Science Diet", price: 70, rating: 4.5, category: "Храна", imageColor: OPTheme.mint, imageIcon: "leaf.fill"),
                ProductRecommendation(id: "f3", name: "Brit Premium Adult", price: 55, rating: 4.3, category: "Храна", imageColor: OPTheme.sky, imageIcon: "leaf.fill"),
            ]
        }
    }

    private var toyProducts: [ProductRecommendation] {
        switch breed {
        case "Лабрадор":
            return [
                ProductRecommendation(id: "t1", name: "Kong Classic XL", price: 35, rating: 4.9, category: "Играчки", imageColor: OPTheme.rose, imageIcon: "circle.fill"),
                ProductRecommendation(id: "t2", name: "Chuckit Ball Launcher", price: 45, rating: 4.7, category: "Играчки", imageColor: OPTheme.mint, imageIcon: "figure.run"),
                ProductRecommendation(id: "t3", name: "Nylabone Power Chew", price: 28, rating: 4.5, category: "Играчки", imageColor: OPTheme.sky, imageIcon: "star.fill"),
            ]
        case "Френски булдог":
            return [
                ProductRecommendation(id: "t1", name: "Kong Puppy Small", price: 22, rating: 4.8, category: "Играчки", imageColor: OPTheme.rose, imageIcon: "circle.fill"),
                ProductRecommendation(id: "t2", name: "Snuffle Mat", price: 38, rating: 4.6, category: "Играчки", imageColor: OPTheme.mint, imageIcon: "square.grid.3x3.fill"),
                ProductRecommendation(id: "t3", name: "Cooling Toy Ring", price: 18, rating: 4.4, category: "Играчки", imageColor: OPTheme.sky, imageIcon: "snowflake"),
            ]
        default:
            return [
                ProductRecommendation(id: "t1", name: "Kong Classic", price: 30, rating: 4.8, category: "Играчки", imageColor: OPTheme.rose, imageIcon: "circle.fill"),
                ProductRecommendation(id: "t2", name: "Въже за дърпане", price: 18, rating: 4.5, category: "Играчки", imageColor: OPTheme.mint, imageIcon: "line.diagonal"),
                ProductRecommendation(id: "t3", name: "Пъзел за лакомства", price: 42, rating: 4.7, category: "Играчки", imageColor: OPTheme.sky, imageIcon: "puzzlepiece.fill"),
            ]
        }
    }

    private var groomingProducts: [ProductRecommendation] {
        switch breed {
        case "Лабрадор":
            return [
                ProductRecommendation(id: "g1", name: "FURminator Deshedding L", price: 55, rating: 4.8, category: "Грижа", imageColor: OPTheme.primary, imageIcon: "comb.fill"),
                ProductRecommendation(id: "g2", name: "Шампоан за къса козина", price: 25, rating: 4.5, category: "Грижа", imageColor: OPTheme.sky, imageIcon: "drop.fill"),
                ProductRecommendation(id: "g3", name: "Балсам за блясък", price: 22, rating: 4.3, category: "Грижа", imageColor: OPTheme.accent, imageIcon: "sparkles"),
            ]
        case "Френски булдог":
            return [
                ProductRecommendation(id: "g1", name: "Кърпички за гънки", price: 18, rating: 4.7, category: "Грижа", imageColor: OPTheme.primary, imageIcon: "bandage.fill"),
                ProductRecommendation(id: "g2", name: "Хипоалергенен шампоан", price: 32, rating: 4.8, category: "Грижа", imageColor: OPTheme.sky, imageIcon: "drop.fill"),
                ProductRecommendation(id: "g3", name: "Крем за лапи", price: 15, rating: 4.4, category: "Грижа", imageColor: OPTheme.accent, imageIcon: "hand.raised.fill"),
            ]
        default:
            return [
                ProductRecommendation(id: "g1", name: "Четка Slicker Brush", price: 28, rating: 4.6, category: "Грижа", imageColor: OPTheme.primary, imageIcon: "comb.fill"),
                ProductRecommendation(id: "g2", name: "Универсален шампоан", price: 20, rating: 4.4, category: "Грижа", imageColor: OPTheme.sky, imageIcon: "drop.fill"),
                ProductRecommendation(id: "g3", name: "Ножица за нокти", price: 15, rating: 4.3, category: "Грижа", imageColor: OPTheme.accent, imageIcon: "scissors"),
            ]
        }
    }

    private var healthTips: [BreedHealthTip] {
        switch breed {
        case "Лабрадор":
            return [
                BreedHealthTip(id: "h1", icon: "figure.walk", title: "Нужда от движение", description: "Лабрадорите се нуждаят от минимум 60 минути активна разходка дневно. Липсата на движение води до затлъстяване.", severity: .info),
                BreedHealthTip(id: "h2", icon: "exclamationmark.triangle.fill", title: "Дисплазия на тазобедрена става", description: "Лабрадорите са склонни към дисплазия на тазобедрена става. Препоръчваме контролни прегледи на всеки 6 месеца.", severity: .important),
                BreedHealthTip(id: "h3", icon: "scalemass.fill", title: "Риск от затлъстяване", description: "Породата е предразположена към наднормено тегло. Следи порциите и избягвай допълнителни лакомства.", severity: .warning),
            ]
        case "Френски булдог":
            return [
                BreedHealthTip(id: "h1", icon: "lungs.fill", title: "Проблеми с дишането", description: "Френските булдози имат брахицефален синдром. Избягвай интензивни натоварвания и горещо време.", severity: .important),
                BreedHealthTip(id: "h2", icon: "allergens.fill", title: "Кожни алергии", description: "Породата е склонна към кожни алергии. Почиствай гънките на лицето ежедневно и следи за зачервявания.", severity: .warning),
                BreedHealthTip(id: "h3", icon: "water.waves", title: "Не може да плува", description: "Френските булдози НЕ могат да плуват поради телосложението си. Никога не ги оставяй без надзор близо до вода.", severity: .important),
                BreedHealthTip(id: "h4", icon: "thermometer.sun.fill", title: "Прегряване", description: "Много чувствителни към горещина. При температури над 25C ограничи разходките до ранна сутрин и късна вечер.", severity: .warning),
            ]
        case "Голдън ретривър":
            return [
                BreedHealthTip(id: "h1", icon: "cross.case.fill", title: "Риск от рак", description: "Голдън ретривърите имат повишен риск от рак (60%). Редовните прегледи са критични след 6-годишна възраст.", severity: .important),
                BreedHealthTip(id: "h2", icon: "figure.walk", title: "Дисплазия на тазобедрена и лакътна става", description: "Склонни към ставни проблеми. Поддържай здравословно тегло и давай добавки за стави.", severity: .warning),
                BreedHealthTip(id: "h3", icon: "ear.fill", title: "Ушни инфекции", description: "Висящите уши задържат влага. Проверявай и почиствай ушите поне веднъж седмично.", severity: .info),
            ]
        default:
            return [
                BreedHealthTip(id: "h1", icon: "heart.fill", title: "Редовни прегледи", description: "Препоръчваме ветеринарен преглед поне 2 пъти годишно за оптимално здраве.", severity: .info),
                BreedHealthTip(id: "h2", icon: "figure.walk", title: "Активен начин на живот", description: "Осигурете минимум 30-60 минути разходка дневно според породата и възрастта.", severity: .info),
            ]
        }
    }
}
