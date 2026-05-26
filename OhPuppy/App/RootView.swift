import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedTab = 0
    @Namespace private var tabAnimation

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingView()
            } else if !store.isAuthenticated {
                SignInView()
            } else {
                mainContent
            }
        }
        .preferredColorScheme(store.isDarkMode ? .dark : .light)
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack { HomeView() }
                case 1:
                    NavigationStack { DogListView() }
                case 2:
                    NavigationStack { MapView() }
                case 3:
                    NavigationStack { ChatView() }
                case 4:
                    NavigationStack { SettingsView() }
                default:
                    NavigationStack { HomeView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            floatingTabBar
        }
    }

    private let tabs: [(icon: String, iconFilled: String, label: String)] = [
        ("house", "house.fill", "Начало"),
        ("pawprint", "pawprint.fill", "Кучета"),
        ("map", "map.fill", "Карта"),
        ("bubble.left.and.bubble.right", "bubble.left.and.bubble.right.fill", "Чат"),
        ("person", "person.fill", "Профил"),
    ]

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == index {
                                Capsule()
                                    .fill(OPTheme.primary.opacity(0.12))
                                    .frame(width: 48, height: 30)
                                    .matchedGeometryEffect(id: "tabHighlight", in: tabAnimation)
                            }

                            Image(systemName: selectedTab == index ? tab.iconFilled : tab.icon)
                                .font(.system(size: 18, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundStyle(selectedTab == index ? OPTheme.primary : OPTheme.textTertiary)
                                .symbolEffect(.bounce.up, value: selectedTab == index)
                        }
                        .frame(height: 30)

                        Text(tab.label)
                            .font(.system(size: 10, weight: selectedTab == index ? .bold : .medium))
                            .foregroundStyle(selectedTab == index ? OPTheme.primary : OPTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(OPTheme.border.opacity(0.5), lineWidth: 0.5)
                }
                .shadow(color: OPTheme.primary.opacity(0.08), radius: 20, y: -4)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 2)
    }
}
