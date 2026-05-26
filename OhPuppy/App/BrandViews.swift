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

    private var approved: Int { store.brandProducts.filter { $0.status == .approved }.count }
    private var pending: Int { store.brandProducts.filter { $0.status == .pending }.count }
    private var rejected: Int { store.brandProducts.filter { $0.status == .rejected }.count }

    private var recentOrders: [BrandOrder] {
        Array(store.brandOrders.sorted { $0.orderedAt > $1.orderedAt }.prefix(3))
    }

    private var lowStockProducts: [BrandProduct] {
        // Mock low stock: first 2 approved products
        Array(store.brandProducts.filter { $0.status == .approved }.prefix(2))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                DashboardRoleSwitcher()
                headerCard
                analyticsRow
                approvalStatusSection
                recentOrdersSection
                lowStockSection
                addProductButton
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddProduct) { AddBrandProductSheet() }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(OPTheme.accentGradient)
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(store.ownerName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.success)
                    Text("Верифициран бранд")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.success)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.accent.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Analytics

    private var analyticsRow: some View {
        HStack(spacing: 10) {
            brandAnalyticCard(value: "\(store.brandProducts.count)", label: "Продукти", icon: "shippingbox.fill", color: OPTheme.sky)
            brandAnalyticCard(value: "\(approved)", label: "Одобрени", icon: "checkmark.seal.fill", color: OPTheme.accent)
            brandAnalyticCard(value: "\(store.brandOrders.count)", label: "Поръчки", icon: "bag.fill", color: OPTheme.success)
        }
    }

    private func brandAnalyticCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Approval Status

    private var approvalStatusSection: some View {
        HStack(spacing: 10) {
            brandStatusPill(count: approved, label: "Одобрени", color: OPTheme.success)
            brandStatusPill(count: pending, label: "Чакащи", color: OPTheme.warning)
            brandStatusPill(count: rejected, label: "Отказани", color: OPTheme.danger)
        }
    }

    private func brandStatusPill(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(color.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Recent Orders

    private var recentOrdersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Скорошни поръчки")

            if recentOrders.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Няма поръчки все още")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(recentOrders) { order in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(brandOrderStatusColor(order.status).opacity(0.12))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(brandOrderStatusColor(order.status))
                            }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(order.productName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                                .lineLimit(1)
                            Text("\(order.buyerName) \u{00B7} \(order.orderedAt.shortBG)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(String(format: "%.2f лв", order.totalPrice))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            brandOrderBadge(order.status)
                        }
                    }
                    .padding(12)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Low Stock

    private var lowStockSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Нисък наличен запас")

            if lowStockProducts.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.success)
                    Text("Всички продукти са налични")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(OPTheme.successSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(lowStockProducts) { product in
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(OPTheme.warning)
                            .frame(width: 36, height: 36)
                            .background(OPTheme.warningSoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(product.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                                .lineLimit(1)
                            Text("Остават 3 бр.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.warning)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.warning.opacity(0.3), lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Quick Action

    private var addProductButton: some View {
        Button { showAddProduct = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Добави продукт")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(OPTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
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

    private var totalRevenue: Double {
        store.brandOrders.reduce(0) { $0 + $1.totalPrice }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Store profile header
                storeProfileHeader

                // Revenue card
                revenueCard

                // Store info
                storeInfoSection

                // Role switcher
                roleSwitcherSection

                // App settings
                appSettingsSection

                // Logout
                logoutButton
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .alert("Излизане?", isPresented: $showLogoutAlert) {
            Button("Отказ", role: .cancel) {}
            Button("Излез", role: .destructive) { store.signOut() }
        } message: {
            Text("Сигурни ли сте, че искате да излезете?")
        }
        .sheet(isPresented: $showDarkMode) { DarkModeSheet() }
    }

    private var storeProfileHeader: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(OPTheme.accentGradient)
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                }

            VStack(spacing: 6) {
                Text(store.ownerName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(OPTheme.success)
                    Text("Верифициран бранд")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(OPTheme.success)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.accent.opacity(0.2), lineWidth: 1))
    }

    private var revenueCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(OPTheme.success)
                Text("Приходи")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.2f", totalRevenue))
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(OPTheme.success)
                Text("лв")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(OPTheme.success.opacity(0.7))
                Spacer()
            }
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(store.brandOrders.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.accent)
                    Text("Поръчки")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(OPTheme.accentSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(spacing: 2) {
                    Text("\(store.brandProducts.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.sky)
                    Text("Продукти")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(OPTheme.skySoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(spacing: 2) {
                    let avg = store.brandOrders.isEmpty ? 0.0 : totalRevenue / Double(store.brandOrders.count)
                    Text(String(format: "%.0f лв", avg))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.mint)
                    Text("Ср. поръчка")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(OPTheme.mintSoft.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.success.opacity(0.2), lineWidth: 1))
    }

    private var storeInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("МАГАЗИН")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)

            VStack(spacing: 0) {
                brandSettingsRow(icon: "storefront.fill", label: "Име на магазин", value: store.ownerName, color: OPTheme.accent)
                Divider().padding(.leading, 54)
                brandSettingsRow(icon: "tag.fill", label: "Категория", value: "Зоо артикули", color: OPTheme.mint)
                Divider().padding(.leading, 54)
                brandSettingsRow(icon: "checkmark.seal.fill", label: "Статус", value: "Верифициран", color: OPTheme.success)
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private func brandSettingsRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.text)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var roleSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("РОЛЯ")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)

            let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })
            VStack(spacing: 0) {
                ForEach(Array(availableRoles.enumerated()), id: \.element) { index, role in
                    Button {
                        withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(store.activeRole == role ? OPTheme.primary.opacity(0.12) : OPTheme.surfaceSunken)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: role.icon)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(store.activeRole == role ? OPTheme.primary : OPTheme.textTertiary)
                                }
                            Text(role.label)
                                .font(.system(size: 15, weight: store.activeRole == role ? .bold : .medium))
                                .foregroundStyle(OPTheme.text)
                            Spacer()
                            if store.activeRole == role {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(OPTheme.success)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    if index < availableRoles.count - 1 {
                        Divider().padding(.leading, 54)
                    }
                }
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ПРИЛОЖЕНИЕ")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)

            VStack(spacing: 0) {
                Button { showDarkMode = true } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(OPTheme.primary.opacity(0.12))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(OPTheme.primary)
                            }
                        Text("Тъмен режим")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(OPTheme.text)
                        Spacer()
                        Text(store.isDarkMode ? "Вкл." : "Изкл.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15))
                Text("Изход")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.dangerSoft.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
