import SwiftUI
import MapKit

struct MapDogPin: Identifiable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let distance: String
    let avatarURL: String
    let coordinate: CLLocationCoordinate2D
    let nearbyDogId: String?
}

struct MapWalkerPin: Identifiable {
    let id: String
    let name: String
    let rating: Double
    let pricePerWalk: Int
    let coordinate: CLLocationCoordinate2D
    let badge: WalkerBadge
    let reviewCount: Int
    let walksCount: Int
    let photoURL: String?
}

struct MapView: View {
    @Environment(AppStore.self) private var store
    @State private var locationManager = LocationManager()
    @State private var selectedFilter = "Всички"
    @State private var isFollowing = false
    @State private var showFilterSheet = false
    @State private var showLostDogAlert = false
    @State private var showPlaces = false
    @State private var showEvents = false
    @State private var showPlaydate = false
    @State private var showDogWalkers = false
    @State private var searchText = ""
    @State private var selectedRadius = 5
    @State private var selectedDog: MapDogPin?
    @State private var showPublicProfile = false
    @State private var selectedNearbyDog: NearbyDog?
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @AppStorage("inviteBannerDismissed") private var inviteBannerDismissed = false
    @State private var showInviteShare = false
    @State private var selectedWalker: MapWalkerPin?

    private let filters = ["Всички", "Кучета", "Разходчици", "Места", "Събития", "Изгубени"]

    private var mapDogs: [MapDogPin] {
        guard let center = locationManager.userLocation else {
            let sofia = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)
            return generatePins(around: sofia)
        }
        return generatePins(around: center)
    }

    private var mapWalkers: [MapWalkerPin] {
        guard let center = locationManager.userLocation else {
            let sofia = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)
            return generateWalkerPins(around: sofia)
        }
        return generateWalkerPins(around: center)
    }

    private func generateWalkerPins(around center: CLLocationCoordinate2D) -> [MapWalkerPin] {
        [
            MapWalkerPin(id: "w1", name: "Мария К.", rating: 4.9, pricePerWalk: 25, coordinate: CLLocationCoordinate2D(latitude: center.latitude + 0.004, longitude: center.longitude - 0.002), badge: .legend, reviewCount: 89, walksCount: 210, photoURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&h=100&q=85"),
            MapWalkerPin(id: "w2", name: "Георги П.", rating: 4.7, pricePerWalk: 20, coordinate: CLLocationCoordinate2D(latitude: center.latitude - 0.002, longitude: center.longitude + 0.005), badge: .popular, reviewCount: 34, walksCount: 52, photoURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&h=100&q=85"),
            MapWalkerPin(id: "w3", name: "Елена В.", rating: 4.5, pricePerWalk: 18, coordinate: CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.006), badge: .reliable, reviewCount: 15, walksCount: 28, photoURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&h=100&q=85"),
            MapWalkerPin(id: "w4", name: "Димитър С.", rating: 5.0, pricePerWalk: 30, coordinate: CLLocationCoordinate2D(latitude: center.latitude - 0.003, longitude: center.longitude - 0.004), badge: .expert, reviewCount: 62, walksCount: 115, photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&h=100&q=85"),
            MapWalkerPin(id: "w5", name: "Ива М.", rating: 4.2, pricePerWalk: 15, coordinate: CLLocationCoordinate2D(latitude: center.latitude + 0.005, longitude: center.longitude + 0.003), badge: .newcomer, reviewCount: 3, walksCount: 5, photoURL: nil),
        ]
    }

    private func generatePins(around center: CLLocationCoordinate2D) -> [MapDogPin] {
        [
            MapDogPin(id: "d1", name: store.dogs.first?.name ?? "Рекс", breed: store.dogs.first?.breed ?? "Лабрадор", age: store.dogs.first?.age ?? "4 г.", distance: "Твоето куче", avatarURL: store.dogs.first?.avatarURL?.absoluteString ?? "", coordinate: center, nearbyDogId: nil),
            MapDogPin(id: "d2", name: "Тоби", breed: "Бордер коли", age: "2 г.", distance: "250 м от теб", avatarURL: "https://images.unsplash.com/photo-1551717743-49959800b1f6?auto=format&fit=crop&w=100&h=100&q=85", coordinate: CLLocationCoordinate2D(latitude: center.latitude + 0.002, longitude: center.longitude + 0.003), nearbyDogId: "nd1"),
            MapDogPin(id: "d3", name: "Кокчо", breed: "Шпиц", age: "1 г.", distance: "800 м от теб", avatarURL: "https://images.unsplash.com/photo-1568393691080-7d191a564ef8?auto=format&fit=crop&w=100&h=100&q=85", coordinate: CLLocationCoordinate2D(latitude: center.latitude - 0.003, longitude: center.longitude + 0.001), nearbyDogId: "nd4"),
            MapDogPin(id: "d4", name: "Мила", breed: "Корги", age: "3 г.", distance: "400 м от теб", avatarURL: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=100&h=100&q=85", coordinate: CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude - 0.004), nearbyDogId: "nd2"),
        ]
    }

    var body: some View {
        ZStack {
            mapContent

            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 8)

                filterChips
                    .padding(.top, 10)

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Button {
                            withAnimation {
                                cameraPosition = .userLocation(fallback: .automatic)
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(OPTheme.primaryGradient, in: Circle())
                                .shadow(color: OPTheme.primary.opacity(0.4), radius: 8, y: 3)
                        }

                        NavigationLink(destination: PlaydateView()) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(OPTheme.mintGradient, in: Circle())
                                .shadow(color: OPTheme.mint.opacity(0.4), radius: 8, y: 3)
                        }

                        NavigationLink(destination: DogWalkerView()) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(OPTheme.primaryGradient, in: Circle())
                                .shadow(color: OPTheme.primary.opacity(0.4), radius: 8, y: 3)
                        }
                    }
                    .padding(.trailing, OPTheme.screenPadding)
                }
                .padding(.bottom, 100)
            }

            VStack {
                Spacer()
                if !inviteBannerDismissed {
                    inviteFriendBanner
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                if let walker = selectedWalker, selectedDog == nil {
                    walkerCard(walker)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.bottom, 16)
                } else if selectedDog != nil, selectedWalker == nil {
                    nearbyDogCard
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(OPTheme.quickSpring, value: selectedDog?.id)
            .animation(OPTheme.quickSpring, value: selectedWalker?.id)
            .animation(OPTheme.quickSpring, value: inviteBannerDismissed)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFilterSheet) {
            FilterRadiusSheet(selectedRadius: $selectedRadius)
        }
        .sheet(isPresented: $showLostDogAlert) {
            LostDogView()
        }
        .sheet(isPresented: $showPlaces) {
            NavigationStack {
                PlacesView()
            }
        }
        .sheet(isPresented: $showEvents) {
            NavigationStack {
                EventsView()
            }
        }
        .navigationDestination(isPresented: $showPublicProfile) {
            if let nearby = selectedNearbyDog {
                PublicDogProfileView(dog: nearby)
            }
        }
        .sheet(isPresented: $showInviteShare) {
            ShareSheet(activityItems: ["Хей! Свали OhPuppy и нека се разхождаме заедно с кучетата! \u{1F43E}\nhttps://ohpuppy.bg/download"])
        }
        .onAppear {
            locationManager.requestPermission()
            locationManager.startUpdating()
            if selectedDog == nil, mapDogs.count > 1 {
                selectedDog = mapDogs[1]
            }
        }
    }

    // MARK: - Real Map

    private var mapContent: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            ForEach(mapDogs) { dog in
                Annotation(dog.name, coordinate: dog.coordinate) {
                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            selectedDog = dog
                            selectedWalker = nil
                        }
                    } label: {
                        mapPinLabel(dog: dog)
                    }
                }
            }

            if selectedFilter == "Всички" || selectedFilter == "Разходчици" {
                ForEach(mapWalkers) { walker in
                    Annotation(walker.name, coordinate: walker.coordinate) {
                        Button {
                            withAnimation(OPTheme.quickSpring) {
                                selectedWalker = walker
                                selectedDog = nil
                            }
                        } label: {
                            walkerPinView(walker)
                        }
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.park, .hospital, .store])))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea()
    }

    private func mapPinLabel(dog: MapDogPin) -> some View {
        let isSelected = selectedDog?.id == dog.id
        let isOwnDog = dog.id == "d1"
        return VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: dog.avatarURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(OPTheme.surfaceSunken)
                            .overlay {
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(OPTheme.mint)
                            }
                    }
                }
                .frame(width: isSelected ? 52 : 44, height: isSelected ? 52 : 44)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        isSelected ? AnyShapeStyle(OPTheme.mint) : AnyShapeStyle(OPTheme.avatarRingGradient),
                        lineWidth: isSelected ? 4 : 3
                    )
                )
                .shadow(color: OPTheme.primary.opacity(0.3), radius: 6, y: 3)

                if isOwnDog {
                    DogStatusEmoji()
                        .offset(x: 4, y: 4)
                }

                if isOwnDog && store.acceptsWalkOffers {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(OPTheme.sky, in: Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        .offset(x: -4, y: 4)
                }
            }

            Triangle()
                .fill(isSelected ? OPTheme.mint : OPTheme.primary)
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(OPTheme.quickSpring, value: isSelected)
    }

    // MARK: - Nearby Dog Lookup

    private func nearbyDogFor(pin: MapDogPin) -> NearbyDog? {
        guard let ndId = pin.nearbyDogId else { return nil }
        return nearbyDogsData.first { $0.id == ndId }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
                .symbolEffect(.breathe)
            TextField("Търси район или куче...", text: $searchText)
                .font(.system(size: 15, weight: .medium))
            Spacer()
            Button { showFilterSheet = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.primary)
                    .symbolEffect(.bounce, value: showFilterSheet)
                    .frame(width: 34, height: 34)
                    .background(OPTheme.primarySoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(OPTheme.quickSpring) { selectedFilter = filter }
                        switch filter {
                        case "Разходчици": showDogWalkers = true
                        case "Места": showPlaces = true
                        case "Събития": showEvents = true
                        case "Изгубени": showLostDogAlert = true
                        default: break
                        }
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedFilter == filter ? .white : OPTheme.text)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(.ultraThickMaterial),
                                in: Capsule()
                            )
                            .shadow(color: selectedFilter == filter ? OPTheme.primary.opacity(0.3) : .clear, radius: 4, y: 2)
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Nearby Dog Card

    // MARK: - Invite Friend Banner

    private var inviteFriendBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(OPTheme.accentSoft)
                    .frame(width: 46, height: 46)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(OPTheme.accent)
                    .symbolEffect(.wiggle.byLayer)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Няма кучета наблизо?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("Покани приятел с куче!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            Button { showInviteShare = true } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(OPTheme.primaryGradient, in: Circle())
            }

            Button {
                withAnimation(OPTheme.quickSpring) { inviteBannerDismissed = true }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(OPTheme.textTertiary)
                    .frame(width: 22, height: 22)
                    .background(OPTheme.surfaceSunken, in: Circle())
            }
        }
        .padding(12)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }

    // MARK: - Nearby Dog Card

    // MARK: - Walker Pin

    private func walkerPinView(_ walker: MapWalkerPin) -> some View {
        let isSelected = selectedWalker?.id == walker.id
        let pinSize: CGFloat = switch walker.badge {
        case .legend: 52
        case .expert: 48
        case .popular: 44
        case .reliable: 40
        case .newcomer: 36
        }
        let badgeGradient: LinearGradient = switch walker.badge {
        case .legend: LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FFA500")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .expert: LinearGradient(colors: [Color(hex: "8B5CF6"), Color(hex: "6D28D9")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .popular: LinearGradient(colors: [OPTheme.accent, OPTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .reliable: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .newcomer: LinearGradient(colors: [OPTheme.mint, Color(hex: "2D6A4F")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                if let url = walker.photoURL {
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(badgeGradient)
                                .overlay {
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: pinSize * 0.4, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                    .frame(width: pinSize, height: pinSize)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(badgeGradient, lineWidth: isSelected ? 4 : 3))
                } else {
                    Circle()
                        .fill(badgeGradient)
                        .frame(width: pinSize, height: pinSize)
                        .overlay {
                            Image(systemName: "figure.walk")
                                .font(.system(size: pinSize * 0.4, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                }
                Image(systemName: walker.badge.icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(badgeGradient, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(x: 3, y: 3)
            }
            .shadow(color: .black.opacity(0.25), radius: 6, y: 3)

            Triangle()
                .fill(badgeGradient)
                .frame(width: 10, height: 6)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(OPTheme.quickSpring, value: isSelected)
    }

    // MARK: - Walker Card

    private func walkerCard(_ walker: MapWalkerPin) -> some View {
        let badgeColor: Color = switch walker.badge {
        case .legend: Color(hex: "FFD700")
        case .expert: Color(hex: "8B5CF6")
        case .popular: OPTheme.accent
        case .reliable: OPTheme.sky
        case .newcomer: OPTheme.mint
        }

        return VStack(spacing: 12) {
            HStack(spacing: 14) {
                if let url = walker.photoURL {
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(badgeColor.opacity(0.5), lineWidth: 2))
                } else {
                    Circle()
                        .fill(OPTheme.surfaceSunken)
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(OPTheme.mint)
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(walker.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        HStack(spacing: 3) {
                            Image(systemName: walker.badge.icon)
                                .font(.system(size: 9, weight: .bold))
                            Text(walker.badge.label)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badgeColor.opacity(0.12), in: Capsule())
                    }
                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(OPTheme.accent)
                            Text(String(format: "%.1f", walker.rating))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("(\(walker.reviewCount))")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(OPTheme.textTertiary)
                        }
                        HStack(spacing: 3) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 10))
                                .foregroundStyle(OPTheme.sky)
                            Text("\(walker.walksCount) разходки")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(walker.pricePerWalk)")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(OPTheme.primary)
                    Text("лв")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }

            NavigationLink(destination: WalkerProfileView(name: walker.name, photoURL: walker.photoURL, rating: walker.rating, reviewCount: walker.reviewCount, walksCount: walker.walksCount, badge: walker.badge, pricePerWalk: walker.pricePerWalk, walkerId: walker.id)) {
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Виж профил")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(badgeColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
    }

    // MARK: - Nearby Dog Card

    private var nearbyDogCard: some View {
        let dog = selectedDog ?? mapDogs.first!
        let nearbyDog = nearbyDogFor(pin: dog)
        let isOwnDog = dog.id == "d1"

        return VStack(spacing: 0) {
            HStack(spacing: 14) {
                AsyncImage(url: URL(string: dog.avatarURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 14).fill(OPTheme.surfaceSunken)
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(dog.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("\(dog.breed) \u{00B7} \(dog.age)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(dog.distance)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(OPTheme.mint)
                }

                Spacer()

                if !isOwnDog {
                    Button {
                        withAnimation(OPTheme.quickSpring) { isFollowing.toggle() }
                    } label: {
                        Text(isFollowing ? "Следваш" : "Следвай")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(isFollowing ? OPTheme.primary : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                isFollowing ? AnyShapeStyle(OPTheme.primarySoft) : AnyShapeStyle(OPTheme.primaryGradient),
                                in: Capsule()
                            )
                    }
                    .sensoryFeedback(.impact, trigger: isFollowing)
                }
            }

            if !isOwnDog, nearbyDog != nil {
                Button {
                    selectedNearbyDog = nearbyDog
                    showPublicProfile = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Виж профил")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(OPTheme.mint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(OPTheme.mintSoft.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 10)
            }
        }
        .padding(14)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 16, y: 6)
    }
}

// MARK: - Filter Radius Sheet

struct FilterRadiusSheet: View {
    @Binding var selectedRadius: Int
    @Environment(\.dismiss) private var dismiss
    @State private var sliderValue: Double = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("Радиус на търсене")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Покажи кучета в определен радиус около теб")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.top, 20)

                ZStack {
                    Circle()
                        .fill(OPTheme.mintGradient)
                        .frame(width: 100, height: 100)
                        .shadow(color: OPTheme.mint.opacity(0.3), radius: 12, y: 4)
                    VStack(spacing: 2) {
                        Text("\(Int(sliderValue))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        Text("км")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                VStack(spacing: 8) {
                    Slider(value: $sliderValue, in: 1...50, step: 1)
                        .tint(OPTheme.mint)
                        .padding(.horizontal, 8)

                    HStack {
                        Text("1 км")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                        Spacer()
                        Text("50 км")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)

                HStack(spacing: 10) {
                    ForEach([1, 5, 10, 25], id: \.self) { preset in
                        Button {
                            withAnimation(OPTheme.quickSpring) { sliderValue = Double(preset) }
                        } label: {
                            Text("\(preset) км")
                                .font(.system(size: 13, weight: Int(sliderValue) == preset ? .bold : .medium))
                                .foregroundStyle(Int(sliderValue) == preset ? .white : OPTheme.text)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Int(sliderValue) == preset ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                    in: Capsule()
                                )
                        }
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(OPTheme.bg)
            .navigationTitle("Филтри")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        selectedRadius = Int(sliderValue)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                }
            }
            .presentationDetents([.medium])
            .onAppear { sliderValue = Double(selectedRadius) }
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
