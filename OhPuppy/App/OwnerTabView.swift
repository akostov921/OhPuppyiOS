import SwiftUI

struct OwnerTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack { HomeView() }
            } label: {
                Label("Начало", systemImage: selectedTab == 0 ? "house.fill" : "house")
            }
            Tab(value: 1) {
                NavigationStack { DogListView() }
            } label: {
                Label("Кучета", systemImage: selectedTab == 1 ? "pawprint.fill" : "pawprint")
            }
            Tab(value: 2) {
                NavigationStack { MapView() }
            } label: {
                Label("Карта", systemImage: selectedTab == 2 ? "map.fill" : "map")
            }
            Tab(value: 3) {
                NavigationStack { MarketplaceView() }
            } label: {
                Label("Магазин", systemImage: selectedTab == 3 ? "storefront.fill" : "storefront")
            }
            Tab(value: 4) {
                NavigationStack { SettingsView() }
            } label: {
                Label("Профил", systemImage: selectedTab == 4 ? "person.fill" : "person")
            }
        }
        .tint(OPTheme.primary)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}
