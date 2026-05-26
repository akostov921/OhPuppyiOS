import SwiftUI

// MARK: - Marketplace Product

struct MarketplaceProduct: Identifiable {
    let id: String
    let name: String
    let brandName: String
    let price: Double
    let oldPrice: Double?
    let rating: Double
    let reviewCount: Int
    let category: MarketCategory
    let photoURL: String
    let breedTag: String?
    let description: String
}

enum MarketCategory: String, CaseIterable {
    case all, food, toys, grooming, health, accessories, clothing, beds

    var label: String {
        switch self {
        case .all: "Всички"
        case .food: "Храна"
        case .toys: "Играчки"
        case .grooming: "Грижа"
        case .health: "Здраве"
        case .accessories: "Аксесоари"
        case .clothing: "Дрехи"
        case .beds: "Легла"
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
        case .clothing: "tshirt.fill"
        case .beds: "bed.double.fill"
        }
    }
}

// MARK: - Vet Service

struct VetServiceListing: Identifiable, Hashable {
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
    @Environment(AppStore.self) private var store
    @State private var selectedCategory: MarketCategory = .all
    @State private var searchText = ""
    @State private var selectedProduct: MarketplaceProduct?
    @State private var showProductDetail = false
    @State private var selectedVetService: VetServiceListing?

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

                shelterBanner
                    .padding(.horizontal, OPTheme.screenPadding)
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
        .sheet(item: $selectedVetService) { service in
            VetBookingSheet(service: service)
        }
    }

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

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MarketCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(OPTheme.quickSpring) { selectedCategory = cat }
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

    private var shelterBanner: some View {
        NavigationLink(destination: SheltersView()) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Осинови кученце")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("6 кучета търсят дом")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.rose)
                    .frame(width: 28, height: 28)
                    .background(OPTheme.roseSoft, in: Circle())
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(OPTheme.roseSoft.opacity(0.4)))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.rose.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(PressableCardStyle())
    }

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
                AsyncImage(url: URL(string: product.photoURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(OPTheme.surfaceSunken)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                    }
                }
                .frame(height: 120)
                .clipped()

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
                        VStack(alignment: .leading, spacing: 1) {
                            Text(String(format: "%.2f лв", product.price))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.primary)
                            if let old = product.oldPrice {
                                Text(String(format: "%.2f лв", old))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(OPTheme.textTertiary)
                                    .strikethrough()
                            }
                        }
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
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
        }
        .buttonStyle(PressableCardStyle())
    }

    private var vetServicesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Ветеринарни услуги")
                .padding(.horizontal, OPTheme.screenPadding)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vetServices) { service in
                        Button {
                            selectedVetService = service
                        } label: {
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
                                Text("Запази час")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(OPTheme.mintGradient, in: Capsule())
                            }
                            .padding(14)
                            .frame(width: 200)
                            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
                        }
                        .buttonStyle(PressableCardStyle())
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
            ("Hurtta", "cloud.snow.fill", OPTheme.info),
        ]
    }

    private var brandMarketplaceProducts: [MarketplaceProduct] {
        store.brandProducts
            .filter { $0.status == .approved }
            .map { bp in
                let cat: MarketCategory = {
                    switch bp.category {
                    case "Храна": return .food
                    case "Играчки": return .toys
                    case "Грижа": return .grooming
                    case "Здраве": return .health
                    case "Аксесоари": return .accessories
                    case "Дрехи": return .clothing
                    case "Легла": return .beds
                    default: return .all
                    }
                }()
                return MarketplaceProduct(
                    id: "bp-\(bp.id)",
                    name: bp.name,
                    brandName: "OhPuppy Brand",
                    price: bp.price,
                    oldPrice: nil,
                    rating: 0,
                    reviewCount: 0,
                    category: cat,
                    photoURL: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&h=400&q=85",
                    breedTag: nil,
                    description: "Продукт от верифициран бранд в OhPuppy"
                )
            }
    }

    private var allProducts: [MarketplaceProduct] {
        [
            MarketplaceProduct(id: "p1", name: "Royal Canin French Bulldog", brandName: "Royal Canin", price: 79.90, oldPrice: nil, rating: 4.7, reviewCount: 234, category: .food, photoURL: "https://images.unsplash.com/photo-1589924691995-400dc9ecc119?auto=format&fit=crop&w=400&h=400&q=85", breedTag: "За Френски булдог", description: "Специално разработена храна за Френски булдог. Подпомага храносмилането и поддържа здрава кожа и козина. 12 кг пакет."),
            MarketplaceProduct(id: "p2", name: "Acana Singles Duck", brandName: "Acana", price: 95.00, oldPrice: 110.00, rating: 4.8, reviewCount: 189, category: .food, photoURL: "https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Монопротеинова храна с патица за кучета с чувствителен стомах. Без зърно, натурални съставки."),
            MarketplaceProduct(id: "p3", name: "Kong Puppy Small", brandName: "Kong", price: 24.90, oldPrice: nil, rating: 4.8, reviewCount: 412, category: .toys, photoURL: "https://images.unsplash.com/photo-1535294435445-d7249524ef2e?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Играчка за малки кученца. Мека гума за млечни зъби. Може да се пълни с лакомства за допълнителна стимулация."),
            MarketplaceProduct(id: "p4", name: "Snuffle Mat Pro", brandName: "Trixie", price: 38.00, oldPrice: 45.00, rating: 4.6, reviewCount: 156, category: .toys, photoURL: "https://images.unsplash.com/photo-1601758124277-f0086d5ab253?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Интерактивна подложка за търсене на лакомства. Стимулира обонянието и забавя бързото хранене."),
            MarketplaceProduct(id: "p5", name: "FURminator deShedding L", brandName: "FURminator", price: 52.00, oldPrice: nil, rating: 4.9, reviewCount: 567, category: .grooming, photoURL: "https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Професионална четка за махане на подкосъм. Намалява косопада с до 90%. Размер L за големи породи."),
            MarketplaceProduct(id: "p6", name: "Seresto Нашийник 8 мес", brandName: "Seresto", price: 65.00, oldPrice: nil, rating: 4.5, reviewCount: 321, category: .health, photoURL: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Защита от кърлежи и бълхи за 8 месеца. Без мирис, водоустойчив. За кучета над 8 кг."),
            MarketplaceProduct(id: "p7", name: "GPS Тракер PawTrack", brandName: "PawTrack", price: 89.90, oldPrice: 119.90, rating: 4.3, reviewCount: 89, category: .accessories, photoURL: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "GPS тракер с real-time проследяване. Батерия за 5 дни. Водоустойчив IP67. Включва 3 месеца абонамент."),
            MarketplaceProduct(id: "p8", name: "Зимно яке Hurtta Summit", brandName: "Hurtta", price: 89.00, oldPrice: nil, rating: 4.7, reviewCount: 134, category: .clothing, photoURL: "https://images.unsplash.com/photo-1583511655826-05700d52f4d9?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Топло зимно яке с отражатели. Водоустойчив материал, подплата от мек полар. Размери XS-XXL."),
            MarketplaceProduct(id: "p9", name: "Дъждобран Pawz", brandName: "Pawz", price: 45.00, oldPrice: 55.00, rating: 4.4, reviewCount: 76, category: .clothing, photoURL: "https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Лек дъждобран с качулка. Дишащ материал, лесно се обува. Идеален за дъждовни разходки."),
            MarketplaceProduct(id: "p10", name: "Ортопедично легло MaxComfort", brandName: "PetFusion", price: 129.00, oldPrice: 159.00, rating: 4.8, reviewCount: 203, category: .beds, photoURL: "https://images.unsplash.com/photo-1541599188778-cdc73298e8fd?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Ортопедично легло с мемори пяна. Подпомага ставите и гърба. Свалящ се перящ се калъф. Размер L (90x70 см)."),
            MarketplaceProduct(id: "p11", name: "Уютна къщичка Cave", brandName: "Trixie", price: 75.00, oldPrice: nil, rating: 4.6, reviewCount: 98, category: .beds, photoURL: "https://images.unsplash.com/photo-1601758124510-52d02ddb7cbd?auto=format&fit=crop&w=400&h=400&q=85", breedTag: "За малки породи", description: "Меко плюшено легло-пещера. Идеално за малки породи, които обичат да се гушкат. 45x35 см."),
            MarketplaceProduct(id: "p12", name: "Дентални лакомства Greenies", brandName: "Greenies", price: 18.50, oldPrice: nil, rating: 4.7, reviewCount: 445, category: .health, photoURL: "https://images.unsplash.com/photo-1623387641168-d9803ddd3f35?auto=format&fit=crop&w=400&h=400&q=85", breedTag: nil, description: "Дентални лакомства за ежедневна грижа. Намаляват зъбния камък с до 60%. 12 броя в опаковка."),
        ] + brandMarketplaceProducts
    }

    private var vetServices: [VetServiceListing] {
        [
            VetServiceListing(id: "vs1", vetName: "Д-р Иванов", clinic: "Клиника Лапа", service: "Годишен преглед + ваксини", price: 80, rating: 4.9, avatarIcon: "stethoscope"),
            VetServiceListing(id: "vs2", vetName: "Д-р Петрова", clinic: "VetCare София", service: "Кастрация / Стерилизация", price: 250, rating: 4.8, avatarIcon: "heart.fill"),
            VetServiceListing(id: "vs3", vetName: "Д-р Георгиев", clinic: "Зоо Вита", service: "Почистване на зъби", price: 120, rating: 4.6, avatarIcon: "mouth.fill"),
        ]
    }
}

// MARK: - Vet Booking Sheet

struct VetBookingSheet: View {
    let service: VetServiceListing
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDogId: String = ""
    @State private var appointmentDate = Date()
    @State private var notes = ""
    @State private var showSuccess = false

    private var selectedDog: Dog? {
        store.dogs.first { $0.id == selectedDogId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Vet info card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(OPTheme.mintGradient)
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: service.avatarIcon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(service.vetName)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(OPTheme.text)
                                Text(service.clinic)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                            }
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(OPTheme.accent)
                                Text(String(format: "%.1f", service.rating))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(OPTheme.text)
                            }
                        }

                        HStack {
                            Text(service.service)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                            Spacer()
                            Text("\(service.price) лв")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(OPTheme.primary)
                        }
                    }
                    .padding(16)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border, lineWidth: 1))

                    // Dog picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Избери куче", systemImage: "pawprint.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        if store.dogs.isEmpty {
                            Text("Няма добавени кучета. Добави куче от профила си.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textTertiary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } else {
                            ForEach(store.dogs) { dog in
                                Button {
                                    selectedDogId = dog.id
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: selectedDogId == dog.id ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 18))
                                            .foregroundStyle(selectedDogId == dog.id ? OPTheme.mint : OPTheme.textTertiary)
                                        Text(dog.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(OPTheme.text)
                                        Text(dog.breed)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(OPTheme.textSecondary)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        selectedDogId == dog.id ? OPTheme.mintSoft : OPTheme.surfaceSunken,
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(selectedDogId == dog.id ? OPTheme.mint.opacity(0.4) : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // Date picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Дата и час", systemImage: "calendar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        DatePicker("", selection: $appointmentDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(OPTheme.mint)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Бележки", systemImage: "note.text")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        TextField("Допълнителна информация...", text: $notes, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(3...6)
                            .padding(12)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Submit button
                    Button {
                        let dog = selectedDog
                        let appointment = VetAppointment(
                            id: store.newId(),
                            vetName: service.vetName,
                            clinicName: service.clinic,
                            serviceName: service.service,
                            dogId: dog?.id ?? "",
                            dogName: dog?.name ?? "",
                            date: appointmentDate,
                            notes: notes,
                            status: .upcoming,
                            price: Double(service.price),
                            createdAt: Date()
                        )
                        store.submitVetAppointment(appointment)
                        showSuccess = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Запази час - \(service.price) лв")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.mint.opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(selectedDogId.isEmpty)
                    .opacity(selectedDogId.isEmpty ? 0.5 : 1)
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Запази час")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
            .alert("Часът е запазен!", isPresented: $showSuccess) {
                Button("Готово") { dismiss() }
            } message: {
                Text("Записахме час при \(service.vetName) в \(service.clinic).")
            }
        }
    }
}

// MARK: - Product Detail Sheet

struct ProductDetailSheet: View {
    let product: MarketplaceProduct
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: product.photoURL)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Rectangle().fill(OPTheme.surfaceSunken)
                                .overlay {
                                    ProgressView()
                                }
                        }
                    }
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

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

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(format: "%.2f лв", product.price))
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundStyle(OPTheme.primary)
                            if let old = product.oldPrice {
                                Text(String(format: "%.2f лв", old))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(OPTheme.textTertiary)
                                    .strikethrough()
                                let pct = Int(((old - product.price) / old) * 100)
                                Text("-\(pct)%")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(OPTheme.danger)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(OPTheme.dangerSoft, in: Capsule())
                            }
                        }

                        Divider().padding(.vertical, 8)

                        Text("Описание")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        Text(product.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(OPTheme.textSecondary)
                            .lineSpacing(3)

                        Divider().padding(.vertical, 8)

                        HStack(spacing: 16) {
                            featureChip(icon: "truck.box.fill", text: "Безплатна доставка")
                            featureChip(icon: "arrow.uturn.left", text: "14 дни връщане")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, OPTheme.screenPadding)

                    Button {
                        showCheckout = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Купи сега")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 20)
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
            .sheet(isPresented: $showCheckout) {
                CheckoutSheet(product: product, onDismissParent: { dismiss() })
            }
        }
    }

    private func featureChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(OPTheme.mint)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(OPTheme.mintSoft.opacity(0.5), in: Capsule())
    }
}

// MARK: - Checkout Sheet

struct CheckoutSheet: View {
    let product: MarketplaceProduct
    let onDismissParent: () -> Void
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var address = ""
    @State private var city = ""
    @State private var phone = ""
    @State private var showCardEntry = false
    @State private var showSuccess = false
    @State private var orderNumber = ""

    private let deliveryFee: Double = 5.99
    private var total: Double { product.price + deliveryFee }
    private var hasCard: Bool { !store.savedCardLast4.isEmpty }

    var body: some View {
        NavigationStack {
            if showSuccess {
                orderSuccessView
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        productSummary
                        deliverySection
                        paymentSection
                        orderSummary
                        confirmButton
                    }
                    .padding(OPTheme.screenPadding)
                }
                .background(OPTheme.bg)
                .navigationTitle("Поръчка")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отказ") { dismiss() }
                    }
                }
                .sheet(isPresented: $showCardEntry) { CardEntrySheet() }
                .onAppear {
                    address = store.savedDeliveryAddress
                }
            }
        }
    }

    private var productSummary: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.photoURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(1)
                Text(product.brandName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
            Spacer()
            Text(String(format: "%.2f лв", product.price))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(OPTheme.primary)
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Адрес за доставка", systemImage: "truck.box.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.text)

            TextField("Адрес (ул., бл., ет.)", text: $address)
                .font(.system(size: 15))
                .padding(12)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 10) {
                TextField("Град", text: $city)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                TextField("Телефон", text: $phone)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Начин на плащане", systemImage: "creditcard.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.text)

            if hasCard {
                HStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(OPTheme.mint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Visa ****\(store.savedCardLast4)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                        Text("Запазена карта")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(OPTheme.success)
                }
                .padding(14)
                .background(OPTheme.successSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.success.opacity(0.3), lineWidth: 1))
            } else {
                Button { showCardEntry = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(OPTheme.mint)
                        Text("Добави карта")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                    .padding(14)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var orderSummary: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Продукт")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                Spacer()
                Text(String(format: "%.2f лв", product.price))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
            }
            HStack {
                Text("Доставка")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                Spacer()
                Text(String(format: "%.2f лв", deliveryFee))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
            }
            Divider()
            HStack {
                Text("Общо")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
                Text(String(format: "%.2f лв", total))
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(OPTheme.primary)
            }
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private var confirmButton: some View {
        VStack(spacing: 8) {
            Button {
                if !address.isEmpty { store.savedDeliveryAddress = address }
                orderNumber = "OP-\(Int.random(in: 100000...999999))"
                let order = Order(id: store.newId(), productName: product.name, brandName: product.brandName, price: total, date: Date(), status: .processing, trackingNumber: orderNumber, photoURL: product.photoURL)
                store.placeOrder(order)
                let brandOrder = BrandOrder(id: store.newId(), productId: product.id, productName: product.name, buyerName: store.ownerName, quantity: 1, totalPrice: total, status: .new, orderedAt: Date())
                store.brandOrders.append(brandOrder)
                store.save()
                withAnimation(OPTheme.gentleSpring) { showSuccess = true }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                    Text("Потвърди поръчка - \(String(format: "%.2f лв", total))")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(address.isEmpty || !hasCard)
            .opacity(address.isEmpty || !hasCard ? 0.5 : 1)

            if address.isEmpty || !hasCard {
                Text(address.isEmpty ? "Въведи адрес за доставка" : "Добави карта за плащане")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.danger)
            }
        }
    }

    private var orderSuccessView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(OPTheme.mintGradient)
                .symbolEffect(.bounce, value: showSuccess)

            Text("Поръчката е приета!")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(OPTheme.text)

            Text("Номер: \(orderNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(OPTheme.mint)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(OPTheme.mintSoft, in: Capsule())

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "truck.box.fill")
                        .foregroundStyle(OPTheme.mint)
                    Text("Доставка до 2-4 работни дни")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(OPTheme.accent)
                    Text("Ще получиш известие при изпращане")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }
            .padding(.top, 8)

            Spacer()

            Button {
                dismiss()
                onDismissParent()
            } label: {
                Text("Готово")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 30)
        }
        .background(OPTheme.bg)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
    }
}

// MARK: - Card Entry Sheet

struct CardEntrySheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var holderName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(OPTheme.mintGradient)
                    Text("Добави карта")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                }
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 6) {
                    Text("НОМЕР НА КАРТА")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    TextField("1234 5678 9012 3456", text: $cardNumber)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .keyboardType(.numberPad)
                        .padding(14)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ВАЛИДНОСТ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("MM/ГГ", text: $expiry)
                            .font(.system(size: 16, weight: .medium))
                            .keyboardType(.numberPad)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("CVV")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        SecureField("123", text: $cvv)
                            .font(.system(size: 16, weight: .medium))
                            .keyboardType(.numberPad)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .frame(width: 100)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ИМЕ НА КАРТОДЪРЖАТЕЛ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    TextField("APOSTOL KOSTOV", text: $holderName)
                        .font(.system(size: 16, weight: .medium))
                        .textInputAutocapitalization(.characters)
                        .padding(14)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.success)
                    Text("Защитено плащане. Данните не се съхраняват.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }

                Spacer()

                Button {
                    let last4 = String(cardNumber.suffix(4))
                    store.savedCardLast4 = last4.count == 4 ? last4 : "0000"
                    dismiss()
                } label: {
                    Text("Запази карта")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.mint.opacity(0.3), radius: 10, y: 4)
                }
                .disabled(cardNumber.count < 4)
                .opacity(cardNumber.count < 4 ? 0.5 : 1)
            }
            .padding(OPTheme.screenPadding)
            .background(OPTheme.bg)
            .navigationTitle("Нова карта")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
        }
    }
}
