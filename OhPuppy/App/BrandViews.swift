import SwiftUI

// MARK: - Brand Tab View

struct BrandTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack { BrandHomeView() }
            } label: {
                Label("Начало", systemImage: selectedTab == 0 ? "bag.fill" : "bag")
            }
            Tab(value: 1) {
                NavigationStack { BrandProductsView() }
            } label: {
                Label("Продукти", systemImage: selectedTab == 1 ? "shippingbox.fill" : "shippingbox")
            }
            Tab(value: 2) {
                NavigationStack { BrandOrdersView() }
            } label: {
                Label("Поръчки", systemImage: selectedTab == 2 ? "list.clipboard.fill" : "list.clipboard")
            }
            Tab(value: 3) {
                NavigationStack { BrandSettingsView() }
            } label: {
                Label("Профил", systemImage: selectedTab == 3 ? "person.fill" : "person")
            }
        }
        .tint(OPTheme.accent)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

// MARK: - Brand Home View (Dashboard)

struct BrandHomeView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddProduct = false
    @State private var heroFloat: CGFloat = 0

    private var totalRevenue: Double { store.brandOrders.reduce(0) { $0 + $1.totalPrice } }
    private var todayOrders: [BrandOrder] {
        let cal = Calendar.current
        return store.brandOrders.filter { cal.isDateInToday($0.orderedAt) }
    }
    private var recentOrders: [BrandOrder] {
        Array(store.brandOrders.sorted { $0.orderedAt > $1.orderedAt }.prefix(5))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Добро утро" }
        if hour < 18 { return "Добър ден" }
        return "Добър вечер"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection
                VStack(spacing: 18) {
                    todayHighlight
                    orderPipeline
                    topProducts
                    recentOrdersSection
                    addProductCTA
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showAddProduct) { AddBrandProductSheet() }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { heroFloat = -8 }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(hex: "F4A261"), Color(hex: "E76F51"), Color(hex: "C1440E")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .overlay {
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: ["bag.fill", "shippingbox.fill", "chart.line.uptrend.xyaxis", "star.fill", "tag.fill"][i])
                            .font(.system(size: CGFloat([16, 14, 12, 10, 18][i])))
                            .foregroundStyle(.white.opacity(Double([0.07, 0.05, 0.08, 0.06, 0.04][i])))
                            .offset(
                                x: CGFloat([-70, 90, 50, -40, 110][i]),
                                y: CGFloat([-30, 10, -50, 40, -20][i]) + heroFloat * CGFloat([1, -0.6, 0.8, -1, 0.5][i])
                            )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                DashboardRoleSwitcher()
                    .padding(.bottom, 4)

                Text("\(greeting), \(store.ownerName)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .bold))
                        Text(String(format: "%.0f лв днес", todayOrders.reduce(0) { $0 + $1.totalPrice }))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.white.opacity(0.2), in: Capsule())

                    if !todayOrders.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "bag.fill").font(.system(size: 11))
                            Text("\(todayOrders.count) нови поръчки")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.white.opacity(0.2), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Today Highlight

    private var todayHighlight: some View {
        HStack(spacing: 10) {
            homeHighlightCard(
                value: String(format: "%.0f лв", totalRevenue),
                label: "Общо приходи",
                icon: "chart.line.uptrend.xyaxis",
                color: OPTheme.success,
                gradient: OPTheme.mintGradient
            )
            homeHighlightCard(
                value: "\(store.brandOrders.count)",
                label: "Всички поръчки",
                icon: "bag.fill",
                color: OPTheme.accent,
                gradient: OPTheme.accentGradient
            )
        }
    }

    private func homeHighlightCard(value: String, label: String, icon: String, color: Color, gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(OPTheme.text)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Order Pipeline

    private var orderPipeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Поръчки по статус")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 0) {
                let stages: [(status: BrandOrderStatus, icon: String, color: Color)] = [
                    (.new, "sparkle", OPTheme.accent),
                    (.processing, "gearshape.fill", OPTheme.sky),
                    (.shipped, "paperplane.fill", OPTheme.mint),
                    (.delivered, "checkmark.circle.fill", OPTheme.success),
                ]
                ForEach(Array(stages.enumerated()), id: \.offset) { idx, stage in
                    let count = store.brandOrders.filter { $0.status == stage.status }.count

                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(count > 0 ? stage.color.opacity(0.15) : OPTheme.surfaceSunken)
                                .frame(width: 44, height: 44)
                            Image(systemName: stage.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(count > 0 ? stage.color : OPTheme.textTertiary)
                        }
                        .overlay(alignment: .topTrailing) {
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 18, height: 18)
                                    .background(stage.color, in: Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }

                        Text(stage.status.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)

                    if idx < stages.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(OPTheme.textTertiary.opacity(0.5))
                            .padding(.bottom, 18)
                    }
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Top Products

    private var topProducts: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Топ продукти")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
                Text("\(store.brandProducts.filter { $0.status == .approved }.count) активни")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            let products = Array(store.brandProducts.prefix(3))
            ForEach(Array(products.enumerated()), id: \.element.id) { idx, product in
                HStack(spacing: 12) {
                    Text("#\(idx + 1)")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(idx == 0 ? OPTheme.accent : OPTheme.textTertiary)
                        .frame(width: 28)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            [OPTheme.accentSoft, OPTheme.skySoft, OPTheme.mintSoft.opacity(0.5)][idx % 3]
                        )
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 16))
                                .foregroundStyle([OPTheme.accent, OPTheme.sky, OPTheme.mint][idx % 3])
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                            .lineLimit(1)
                        Text(product.category)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.2f лв", product.price))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        let statusColor: Color = product.status == .approved ? OPTheme.success : product.status == .pending ? OPTheme.warning : OPTheme.danger
                        Text(product.status.label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(statusColor)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(statusColor.opacity(0.12), in: Capsule())
                    }
                }
                if idx < products.count - 1 {
                    Divider().padding(.leading, 40)
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Recent Orders

    private var recentOrdersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Последни поръчки")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(OPTheme.text)

            if recentOrders.isEmpty {
                VStack(spacing: 12) {
                    PlayfulEmptyIcon(icon: "tray")
                    Text("Няма поръчки все още")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 30)
            } else {
                ForEach(recentOrders) { order in
                    let color = brandOrderStatusColor(order.status)
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(color.opacity(0.12)).frame(width: 42, height: 42)
                            Image(systemName: brandOrderIcon(order.status))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(color)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(order.productName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                                .lineLimit(1)
                            HStack(spacing: 6) {
                                Text(order.buyerName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                                Text("\u{00B7}")
                                    .foregroundStyle(OPTheme.textTertiary)
                                Text("\(order.quantity) бр.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 3) {
                            Text(String(format: "%.2f лв", order.totalPrice))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text(order.status.label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(color)
                                .padding(.horizontal, 7).padding(.vertical, 2)
                                .background(color.opacity(0.12), in: Capsule())
                        }
                    }

                    if order.id != recentOrders.last?.id {
                        Divider().padding(.leading, 54)
                    }
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Add Product CTA

    private var addProductCTA: some View {
        Button { showAddProduct = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Добави продукт")
                        .font(.system(size: 16, weight: .bold))
                    Text("Качи нов продукт в каталога")
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.8)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(OPTheme.accentGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: OPTheme.accent.opacity(0.3), radius: 10, y: 4)
        }
    }
}

private func brandOrderIcon(_ status: BrandOrderStatus) -> String {
    switch status {
    case .new: "sparkle"
    case .processing: "gearshape.fill"
    case .shipped: "paperplane.fill"
    case .delivered: "checkmark.circle.fill"
    }
}

// MARK: - Brand Products View

struct BrandProductsView: View {
    @Environment(AppStore.self) private var store
    @State private var searchText = ""
    @State private var selectedFilter: ProductFilter = .all
    @State private var showAddProduct = false

    private enum ProductFilter: String, CaseIterable {
        case all = "Всички"
        case approved = "Одобрени"
        case pending = "Чакащи"
        case rejected = "Отказани"

        var approvalStatus: ApprovalStatus? {
            switch self {
            case .all: nil
            case .approved: .approved
            case .pending: .pending
            case .rejected: .rejected
            }
        }
    }

    private var filteredProducts: [BrandProduct] {
        store.brandProducts.filter { product in
            let matchesFilter: Bool = {
                guard let status = selectedFilter.approvalStatus else { return true }
                return product.status == status
            }()
            let matchesSearch: Bool = {
                guard !searchText.isEmpty else { return true }
                let q = searchText.lowercased()
                return product.name.lowercased().contains(q) || product.category.lowercased().contains(q)
            }()
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                    TextField("Търси продукт...", text: $searchText)
                        .font(.system(size: 15))
                    if !searchText.isEmpty {
                        Button {
                            withAnimation(OPTheme.quickSpring) { searchText = "" }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(OPTheme.textTertiary)
                        }
                    }
                }
                .padding(12)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Status Filter
                HStack(spacing: 8) {
                    ForEach(ProductFilter.allCases, id: \.self) { filter in
                        let isSelected = selectedFilter == filter
                        Button {
                            withAnimation(OPTheme.quickSpring) { selectedFilter = filter }
                        } label: {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? .white : OPTheme.text)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    isSelected ? AnyShapeStyle(OPTheme.accentGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                    in: Capsule()
                                )
                        }
                    }
                    Spacer()
                }

                // Product List
                if filteredProducts.isEmpty {
                    VStack(spacing: 12) {
                        PlayfulEmptyIcon(icon: "shippingbox")
                        Text("Няма продукти в тази категория")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(filteredProducts) { product in
                        brandProductCard(product)
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 100)
        }
        .background(OPTheme.bg)
        .navigationTitle("Продукти")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) {
            Button { showAddProduct = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(OPTheme.accentGradient, in: Circle())
                    .shadow(color: OPTheme.accent.opacity(0.4), radius: 12, y: 6)
            }
            .padding(.trailing, OPTheme.screenPadding)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showAddProduct) { AddBrandProductSheet() }
    }

    private func brandProductCard(_ product: BrandProduct) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(OPTheme.surfaceSunken)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(OPTheme.accent.opacity(0.6))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(1)
                Text(product.category)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.2f лв", product.price))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                brandApprovalBadge(product.status)
            }
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        .contextMenu {
            Button(role: .destructive) {
                withAnimation(OPTheme.quickSpring) {
                    store.removeBrandProduct(id: product.id)
                }
            } label: {
                Label("Изтрий", systemImage: "trash")
            }
        }
    }

    private func brandApprovalBadge(_ status: ApprovalStatus) -> some View {
        let color: Color = switch status {
        case .approved: OPTheme.success
        case .pending: OPTheme.warning
        case .rejected: OPTheme.danger
        }
        return Text(status.label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Brand Orders View

struct BrandOrdersView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedSegment: BrandOrderStatus = .new

    private var filteredOrders: [BrandOrder] {
        store.brandOrders
            .filter { $0.status == selectedSegment }
            .sorted { $0.orderedAt > $1.orderedAt }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            HStack(spacing: 6) {
                ForEach(BrandOrderStatus.allCases, id: \.self) { status in
                    let isSelected = selectedSegment == status
                    let count = store.brandOrders.filter { $0.status == status }.count
                    Button {
                        withAnimation(OPTheme.quickSpring) { selectedSegment = status }
                    } label: {
                        VStack(spacing: 2) {
                            Text(brandOrderSegmentLabel(status))
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? .white : OPTheme.text)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(isSelected ? .white.opacity(0.8) : OPTheme.textTertiary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isSelected ? AnyShapeStyle(OPTheme.accentGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    if filteredOrders.isEmpty {
                        brandOrderEmptyState
                    } else {
                        ForEach(filteredOrders) { order in
                            brandOrderCard(order)
                        }
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationTitle("Поръчки")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func brandOrderSegmentLabel(_ status: BrandOrderStatus) -> String {
        switch status {
        case .new: "Нови"
        case .processing: "Обработва се"
        case .shipped: "Изпратени"
        case .delivered: "Доставени"
        }
    }

    private var brandOrderEmptyState: some View {
        VStack(spacing: 12) {
            PlayfulEmptyIcon(icon: "tray")
            Text(brandOrderEmptyText)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var brandOrderEmptyText: String {
        switch selectedSegment {
        case .new: "Няма нови поръчки"
        case .processing: "Няма поръчки в обработка"
        case .shipped: "Няма изпратени поръчки"
        case .delivered: "Няма доставени поръчки"
        }
    }

    private func brandOrderCard(_ order: BrandOrder) -> some View {
        VStack(spacing: 0) {
            // Order info
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(brandOrderStatusColor(order.status).opacity(0.12))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(brandOrderStatusColor(order.status))
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.productName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        Label(order.buyerName, systemImage: "person.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                        Text("\u{00B7}")
                            .foregroundStyle(OPTheme.textTertiary)
                        Text("\(order.quantity) бр.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%.2f лв", order.totalPrice))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.accent)
                    Text(order.orderedAt.shortBG)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }
            }

            // Status badge
            HStack {
                Spacer()
                brandOrderBadge(order.status)
            }
            .padding(.top, 8)

            // Action button based on status
            if let action = brandOrderAction(for: order) {
                Button {
                    withAnimation(OPTheme.quickSpring) { action.perform() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: action.icon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(action.label)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(action.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 12)
            }
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private struct OrderAction {
        let label: String
        let icon: String
        let gradient: LinearGradient
        let perform: () -> Void
    }

    private func brandOrderAction(for order: BrandOrder) -> OrderAction? {
        switch order.status {
        case .new:
            return OrderAction(
                label: "Обработи",
                icon: "arrow.right.circle.fill",
                gradient: OPTheme.accentGradient,
                perform: { store.updateBrandOrderStatus(id: order.id, status: .processing) }
            )
        case .processing:
            return OrderAction(
                label: "Изпрати",
                icon: "paperplane.fill",
                gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing),
                perform: { store.updateBrandOrderStatus(id: order.id, status: .shipped) }
            )
        case .shipped:
            return OrderAction(
                label: "Доставено",
                icon: "checkmark.circle.fill",
                gradient: OPTheme.mintGradient,
                perform: { store.updateBrandOrderStatus(id: order.id, status: .delivered) }
            )
        case .delivered:
            return nil
        }
    }
}

// MARK: - Brand Settings View

struct BrandSettingsView: View {
    @Environment(AppStore.self) private var store
    @State private var showLogoutAlert = false
    @State private var showDarkMode = false
    @State private var showAddProduct = false
    @State private var heroFloat: CGFloat = 0

    private var totalRevenue: Double { store.brandOrders.reduce(0) { $0 + $1.totalPrice } }
    private var avgOrder: Double { store.brandOrders.isEmpty ? 0 : totalRevenue / Double(store.brandOrders.count) }
    private var deliveredCount: Int { store.brandOrders.filter { $0.status == .delivered }.count }

    private let mockRevenueWeek: [Double] = [120, 89, 210, 45, 180, 95, 252]
    private let mockWeekLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Нд"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroHeader
                statsGrid
                    .padding(.top, -36)
                    .padding(.horizontal, OPTheme.screenPadding)

                VStack(spacing: 20) {
                    quickActions
                    revenueChart
                    socialProof
                    storeDetails
                    roleSwitcherSection
                    settingsRow
                    logoutButton
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .alert("Излизане?", isPresented: $showLogoutAlert) {
            Button("Отказ", role: .cancel) {}
            Button("Излез", role: .destructive) { store.signOut() }
        } message: {
            Text("Сигурни ли сте, че искате да излезете?")
        }
        .sheet(isPresented: $showDarkMode) { DarkModeSheet() }
        .sheet(isPresented: $showAddProduct) { AddBrandProductSheet() }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { heroFloat = -6 }
        }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "F4A261"), Color(hex: "E76F51"), Color(hex: "D62828")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 280)
            .overlay {
                ZStack {
                    ForEach(0..<4, id: \.self) { i in
                        Image(systemName: "bag.fill")
                            .font(.system(size: CGFloat([14, 18, 12, 16][i])))
                            .foregroundStyle(.white.opacity(Double([0.08, 0.06, 0.1, 0.05][i])))
                            .offset(
                                x: CGFloat([-60, 80, 40, -90][i]),
                                y: CGFloat([-40, 20, -70, 50][i]) + heroFloat * CGFloat([1, -0.7, 0.5, -1][i])
                            )
                    }
                }
            }

            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(.white.opacity(0.2)).frame(width: 96, height: 96)
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
                        .overlay {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(OPTheme.accentGradient)
                        }
                }

                Text(store.ownerName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 13))
                    Text("Верифициран бранд").font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(.white.opacity(0.2), in: Capsule())

                HStack(spacing: 16) {
                    brandHeroStat(value: "847", label: "последователи")
                    Circle().fill(.white.opacity(0.4)).frame(width: 4, height: 4)
                    brandHeroStat(value: "4.8", label: "рейтинг")
                    Circle().fill(.white.opacity(0.4)).frame(width: 4, height: 4)
                    brandHeroStat(value: "\(store.brandProducts.filter { $0.status == .approved }.count)", label: "продукти")
                }
                .padding(.top, 4)
            }
            .padding(.bottom, 52)
        }
    }

    private func brandHeroStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 10) {
            brandStatCard(value: String(format: "%.0f лв", totalRevenue), label: "Приходи", icon: "chart.line.uptrend.xyaxis", color: OPTheme.success)
            brandStatCard(value: "\(store.brandOrders.count)", label: "Поръчки", icon: "bag.fill", color: OPTheme.accent)
            brandStatCard(value: String(format: "%.0f лв", avgOrder), label: "Ср. поръчка", icon: "equal.circle.fill", color: OPTheme.sky)
        }
    }

    private func brandStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15), in: Circle())
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(OPTheme.text)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 10) {
            brandQuickAction(icon: "plus.circle.fill", label: "Нов продукт", gradient: OPTheme.accentGradient) { showAddProduct = true }
            brandQuickAction(icon: "list.clipboard.fill", label: "Поръчки", gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing)) {}
            brandQuickAction(icon: "megaphone.fill", label: "Промоция", gradient: LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing)) {}
        }
    }

    private func brandQuickAction(icon: String, label: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Revenue Chart

    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Приходи тази седмица")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .bold)).foregroundStyle(OPTheme.success)
                        Text("+23% спрямо миналата").font(.system(size: 12, weight: .semibold)).foregroundStyle(OPTheme.success)
                    }
                }
                Spacer()
                Text(String(format: "%.0f лв", mockRevenueWeek.reduce(0, +)))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(OPTheme.accent)
            }

            let maxVal = mockRevenueWeek.max() ?? 1
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(i == 6
                                ? LinearGradient(colors: [OPTheme.accent, OPTheme.accentDark], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [OPTheme.accent.opacity(0.3), OPTheme.accent.opacity(0.15)], startPoint: .top, endPoint: .bottom))
                            .frame(height: max(8, CGFloat(mockRevenueWeek[i] / maxVal) * 80))
                        Text(mockWeekLabels[i])
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(i == 6 ? OPTheme.accent : OPTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Social Proof

    private var socialProof: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Клиентски отзиви")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "star.fill").font(.system(size: 13)).foregroundStyle(OPTheme.accent)
                    Text("4.8").font(.system(size: 14, weight: .bold)).foregroundStyle(OPTheme.text)
                    Text("(62)").font(.system(size: 12, weight: .medium)).foregroundStyle(OPTheme.textSecondary)
                }
            }

            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(i < 4 ? OPTheme.accent : OPTheme.accent.opacity(0.3))
                }
                Spacer()
            }

            VStack(spacing: 8) {
                brandReviewRow(name: "Мария К.", text: "Страхотно качество! Кучето обожава храната.", rating: 5, daysAgo: 2)
                brandReviewRow(name: "Георги П.", text: "Бърза доставка, ще поръчам пак.", rating: 4, daysAgo: 5)
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func brandReviewRow(name: String, text: String, rating: Int, daysAgo: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle().fill(OPTheme.accentGradient).frame(width: 28, height: 28)
                    .overlay { Text(String(name.prefix(1))).font(.system(size: 12, weight: .bold)).foregroundStyle(.white) }
                Text(name).font(.system(size: 13, weight: .bold)).foregroundStyle(OPTheme.text)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<rating, id: \.self) { _ in
                        Image(systemName: "star.fill").font(.system(size: 9)).foregroundStyle(OPTheme.accent)
                    }
                }
                Text("преди \(daysAgo) дни").font(.system(size: 10, weight: .medium)).foregroundStyle(OPTheme.textTertiary)
            }
            Text(text).font(.system(size: 13, weight: .medium)).foregroundStyle(OPTheme.textSecondary).lineLimit(2)
        }
        .padding(10)
        .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Store Details

    private var storeDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация за магазина").font(.system(size: 15, weight: .bold)).foregroundStyle(OPTheme.text)

            VStack(spacing: 0) {
                brandDetailRow(icon: "storefront.fill", label: "Име", value: store.ownerName, color: OPTheme.accent)
                Divider().padding(.leading, 52)
                brandDetailRow(icon: "envelope.fill", label: "Имейл", value: store.ownerEmail.isEmpty ? "—" : store.ownerEmail, color: OPTheme.sky)
                Divider().padding(.leading, 52)
                brandDetailRow(icon: "tag.fill", label: "Категория", value: "Зоо артикули", color: OPTheme.mint)
                Divider().padding(.leading, 52)
                brandDetailRow(icon: "clock.fill", label: "Член от", value: "Май 2026", color: OPTheme.rose)
                Divider().padding(.leading, 52)
                brandDetailRow(icon: "shippingbox.fill", label: "Доставки", value: "\(deliveredCount) завършени", color: OPTheme.success)
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private func brandDetailRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(label).font(.system(size: 14, weight: .medium)).foregroundStyle(OPTheme.textSecondary)
            Spacer()
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundStyle(OPTheme.text).lineLimit(1)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }

    // MARK: - Role Switcher

    private var roleSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Превключи роля").font(.system(size: 15, weight: .bold)).foregroundStyle(OPTheme.text)

            let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(availableRoles, id: \.self) { role in
                        let isActive = store.activeRole == role
                        Button {
                            withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: role.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(isActive ? .white : OPTheme.textSecondary)
                                    .frame(width: 44, height: 44)
                                    .background(isActive ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                Text(role.label)
                                    .font(.system(size: 11, weight: isActive ? .bold : .medium))
                                    .foregroundStyle(isActive ? OPTheme.primary : OPTheme.textSecondary)
                            }
                            .frame(width: 72)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Settings

    private var settingsRow: some View {
        Button { showDarkMode = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "moon.fill").font(.system(size: 14, weight: .semibold)).foregroundStyle(OPTheme.primary)
                    .frame(width: 30, height: 30)
                    .background(OPTheme.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text("Тъмен режим").font(.system(size: 15, weight: .medium)).foregroundStyle(OPTheme.text)
                Spacer()
                Text(store.isDarkMode ? "Вкл." : "Изкл.").font(.system(size: 13, weight: .semibold)).foregroundStyle(OPTheme.textSecondary)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(OPTheme.textTertiary)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
        }
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button { showLogoutAlert = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14))
                Text("Изход").font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.dangerSoft.opacity(0.4), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

// MARK: - Shared Helpers

private func brandOrderStatusColor(_ status: BrandOrderStatus) -> Color {
    switch status {
    case .new: OPTheme.accent
    case .processing: OPTheme.sky
    case .shipped: OPTheme.mint
    case .delivered: OPTheme.success
    }
}

private func brandOrderBadge(_ status: BrandOrderStatus) -> some View {
    let color = brandOrderStatusColor(status)
    return Text(status.label)
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.12), in: Capsule())
}
