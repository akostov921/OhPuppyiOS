import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingView()
            } else if !store.isAuthenticated {
                SignInView()
            } else {
                Group {
                    switch store.activeRole {
                    case .owner: OwnerTabView()
                    case .vet: VetTabView()
                    case .walker: WalkerTabView()
                    case .brand: BrandTabView()
                    case .shelter: ShelterTabView()
                    }
                }
                .id(store.activeRole)
            }
        }
        .preferredColorScheme(store.isDarkMode ? .dark : .light)
    }
}
