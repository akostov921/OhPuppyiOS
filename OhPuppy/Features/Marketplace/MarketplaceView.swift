import SwiftUI

// MARK: - Marketplace Product

struct MarketplaceProduct: Identifiable {
    let id: String
    let name: String
    let brandName: String
    let price: Int
    let rating: Double
    let reviewCount: Int
    let category: MarketCategory
    let imageColor: Color
    let imageIcon: String
    let breedTag: String?
}

enum MarketCategory: String, CaseIterable {
    case all, food, toys, grooming, health, accessories

    var label: String {
        switch self {
        case .all: "Всички"
        case .food: "Храна"
        case .toys: "Играчки"
        case .grooming: "Грижа"
        case .health: "Здраве"
        case .accessories: "Аксесоари"
        }
    }

    var icon: String {
        switch self {
        case .all: "square.grid.2x2.fill"
        case .food: "fork.knife"
        case .toys: "gamecontroller.fill"
        case .grooming: "sparkles"
        case .health: "cross.vial.fill"
        case .accessories: "bag.fill"
        }
    }
}

// MARK: - Vet Service

struct VetServiceListing: Identifiable {
    let id: String
    let vetName: String
    let clinic: String
    let service: String
    let price: Int
    let rating: Double
    let avatarIcon: String
}

// MARK: - Marketplace View

struct MarketplaceView: View {
    @State private var selectedCategory: MarketCategory = .all
    @State private var searchText = ""
    @State private var selectedProduct: MarketplaceProduct?
    @State private var showProductDetail = false

    var filteredProducts: [MarketplaceProduct] {
        var result = allProducts
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.brandName.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                searchBar
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 16)

                categoryChips
                    .padding(.bottom, 20)

                brandCorner
                    .padding(.bottom, 24)

                productsGrid
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                vetServicesSection
                    .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                ProductDetailSheet(product: product)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Магазин")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Продукти и услуги за кучета")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "storefront.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(OPTheme.mint)
                    .frame(width: 44, height: 44)
                    .background(OPTheme.mintSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
            TextField("Търси продукт или бранд...", text: $searchText)
                .font(.system(size: 15))
        }
        .padding(12)
        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MarketCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.label)
                                .font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                        }
                        .foregroundStyle(selectedCategory == cat ? .white : OPTheme.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == cat ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                            in: Capsule()
                        )
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Brand Corner

    private var brandCorner: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Популярни брандове")
                .padding(.horizontal, OPTheme.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(brands, id: \.name) { brand in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(brand.color.opacity(0.1))
                                .frame(width: 72, height: 72)
                                .overlay {
                                    Image(systemName: brand.icon)
                                        .font(.system(size: 24))
                                        .foregroundStyle(brand.color)
                                }
                            Text(brand.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                                .lineLimit(1)
                        }
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Products Grid

    private var productsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
            ForEach(filteredProducts) { product in
                productCard(product)
            }
        }
    }

    private func productCard(_ product: MarketplaceProduct) -> some View {
        Button {
            selectedProduct = product
            showProductDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(product.imageColor.opacity(0.12))
                    .frame(height: 110)
                    .overlay {
                        Image(systemName: product.imageIcon)
                            .font(.system(size: 32))
                            .foregroundStyle(product.imageColor)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(product.brandName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)

                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(OPTheme.accent)
                        Text(String(format: "%.1f", product.rating))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                        Text("(\(product.reviewCount))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }

                    if let tag = product.breedTag {
                        Text(tag)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(OPTheme.mint)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(OPTheme.mintSoft, in: Capsule())
                    }

                    HStack {
                        Text("\(product.price) лв")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(OPTheme.primary)
                        Spacer()
                        Text("Купи")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(OPTheme.primaryGradient, in: Capsule())
                    }
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
        .buttonStyle(PressableCardStyle())
    }

    // MARK: - Vet Services

    private var vetServicesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Ветеринарни услуги")
                .padding(.horizontal, OPTheme.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vetServices) { service in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(OPTheme.mintGradient)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Image(systemName: service.avatarIcon)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(service.vetName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(OPTheme.text)
                                    Text(service.clinic)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(OPTheme.textSecondary)
                                }
                            }

                            Text(service.service)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(OPTheme.text)

                            HStack {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(OPTheme.accent)
                                    Text(String(format: "%.1f", service.rating))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(OPTheme.text)
                                }
                                Spacer()
                                Text("\(service.price) лв")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(OPTheme.primary)
                            }
                        }
                        .padding(14)
                        .frame(width: 200)
                        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(OPTheme.border, lineWidth: 1)
                        )
                        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Mock Data

    private var brands: [(name: String, icon: String, color: Color)] {
        [
            ("Royal Canin", "leaf.fill", OPTheme.primary),
            ("Acana", "mountain.2.fill", OPTheme.mint),
            ("Kong", "circle.fill", OPTheme.rose),
            ("Trixie", "hare.fill", OPTheme.sky),
            ("Purina", "pawprint.fill", OPTheme.accent),
        ]
    }

    private var allProducts: [MarketplaceProduct] {
        [
            MarketplaceProduct(id: "p1", name: "Royal Canin French Bulldog", brandName: "Royal Canin", price: 79, rating: 4.7, reviewCount: 234, category: .food, imageColor: OPTheme.accent, imageIcon: "leaf.fill", breedTag: "За Френски булдог"),
            MarketplaceProduct(id: "p2", name: "Acana Singles Duck", brandName: "Acana", price: 95, rating: 4.8, reviewCount: 189, category: .food, imageColor: OPTheme.mint, imageIcon: "leaf.fill", breedTag: nil),
            MarketplaceProduct(id: "p3", name: "Kong Puppy Small", brandName: "Kong", price: 24, rating: 4.8, reviewCount: 412, category: .toys, imageColor: OPTheme.rose, imageIcon: "circle.fill", breedTag: nil),
            MarketplaceProduct(id: "p4", name: "Snuffle Mat Pro", brandName: "Trixie", price: 38, rating: 4.6, reviewCount: 156, category: .toys, imageColor: OPTheme.primary, imageIcon: "square.grid.3x3.fill", breedTag: nil),
            MarketplaceProduct(id: "p5", name: "FURminator deShedding", brandName: "FURminator", price: 52, rating: 4.9, reviewCount: 567, category: .grooming, imageColor: OPTheme.sky, imageIcon: "scissors", breedTag: nil),
            MarketplaceProduct(id: "p6", name: "Нашийник Против Кърлежи", brandName: "Seresto", price: 65, rating: 4.5, reviewCount: 321, category: .health, imageColor: OPTheme.success, imageIcon: "shield.fill", breedTag: nil),
            MarketplaceProduct(id: "p7", name: "GPS Тракер AirTag", brandName: "Apple", price: 59, rating: 4.3, reviewCount: 89, category: .accessories, imageColor: OPTheme.textSecondary, imageIcon: "location.fill", breedTag: nil),
            MarketplaceProduct(id: "p8", name: "Зимно Яке за Куче", brandName: "Hurtta", price: 89, rating: 4.7, reviewCount: 134, category: .accessories, imageColor: OPTheme.rose, imageIcon: "cloud.snow.fill", breedTag: nil),
        ]
    }

    private var vetServices: [VetServiceListing] {
        [
            VetServiceListing(id: "vs1", vetName: "Д-р Иванов", clinic: "Клиника Лапа", service: "Годишен преглед + ваксини", price: 80, rating: 4.9, avatarIcon: "stethoscope"),
            VetServiceListing(id: "vs2", vetName: "Д-р Петрова", clinic: "VetCare София", service: "Кастрация / Стерилизация", price: 250, rating: 4.8, avatarIcon: "heart.fill"),
            VetServiceListing(id: "vs3", vetName: "Д-р Георгиев", clinic: "Зоо Вита", service: "Почистване на зъби", price: 120, rating: 4.6, avatarIcon: "mouth.fill"),
        ]
    }
}

// MARK: - Product Detail Sheet

struct ProductDetailSheet: View {
    let product: MarketplaceProduct
    @Environment(\.dismiss) private var dismiss
    @State private var showPurchaseAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(product.imageColor.opacity(0.12))
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: product.imageIcon)
                                .font(.system(size: 60))
                                .foregroundStyle(product.imageColor)
                        }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        Text(product.brandName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)

                        HStack(spacing: 6) {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(OPTheme.accent)
                                Text(String(format: "%.1f", product.rating))
                                    .font(.system(size: 15, weight: .bold))
                            }
                            Text("(\(product.reviewCount) отзива)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }

                        if let tag = product.breedTag {
                            StatPill(label: tag, icon: "pawprint.fill", tone: .mint)
                        }

                        Divider().padding(.vertical, 8)

                        Text("Описание")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        Text("Висококачествен продукт, специално разработен за нуждите на вашето куче. Натурални съставки, без изкуствени добавки.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(OPTheme.textSecondary)
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, OPTheme.screenPadding)

                    Button {
                        showPurchaseAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("\(product.price) лв")
                                .font(.system(size: 18, weight: .bold))
                            Text("·")
                            Text("Добави в количка")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                }
                .padding(.top, 16)
            }
            .background(OPTheme.bg)
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.primary)
                }
            }
            .alert("Добавено в количката!", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\(product.name) е добавен. Функцията за плащане ще бъде налична скоро.")
            }
        }
    }
}
