import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingView()
            } else if !store.isAuthenticated {
                SignInView()
            } else {
                TabView(selection: $selectedTab) {
                    Tab(value: 0) {
                        NavigationStack {
                            HomeView()
                        }
                    } label: {
                        Label {
                            Text("Начало")
                        } icon: {
                            Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                                .symbolEffect(.bounce.up, value: selectedTab == 0)
                        }
                    }

                    Tab(value: 1) {
                        NavigationStack {
                            DogListView()
                        }
                    } label: {
                        Label {
                            Text("Кучета")
                        } icon: {
                            Image(systemName: selectedTab == 1 ? "pawprint.fill" : "pawprint")
                                .symbolEffect(.bounce.up, value: selectedTab == 1)
                        }
                    }

                    Tab(value: 2) {
                        NavigationStack {
                            MapView()
                        }
                    } label: {
                        Label {
                            Text("Карта")
                        } icon: {
                            Image(systemName: selectedTab == 2 ? "map.fill" : "map")
                                .symbolEffect(.bounce.up, value: selectedTab == 2)
                        }
                    }

                    Tab(value: 3) {
                        NavigationStack {
                            ChatView()
                        }
                    } label: {
                        Label {
                            Text("Чат")
                        } icon: {
                            Image(systemName: selectedTab == 3 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                                .symbolEffect(.bounce.up, value: selectedTab == 3)
                        }
                    }

                    Tab(value: 4) {
                        NavigationStack {
                            SettingsView()
                        }
                    } label: {
                        Label {
                            Text("Профил")
                        } icon: {
                            Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                                .symbolEffect(.bounce.up, value: selectedTab == 4)
                        }
                    }
                }
                .tint(OPTheme.primary)
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
        }
        .preferredColorScheme(store.isDarkMode ? .dark : .light)
    }
}
