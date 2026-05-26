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
    @State private var showWalkerPayment = false

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
            MapWalkerPin(id: "w1", name: "Мария К.", rating: 4.9, pricePerWalk: 25, coordinate: CLLocationCoordinate2D(latitude: center.latitude + 0.004, longitude: center.longitude - 0.002)),
            MapWalkerPin(id: "w2", name: "Георги П.", rating: 4.7, pricePerWalk: 20, coordinate: CLLocationCoordinate2D(latitude: center.latitude - 0.002, longitude: center.longitude + 0.005)),
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
                if let walker = selectedWalker {
                    walkerCard(walker)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.bottom, 16)
                }

                if selectedDog != nil {
                    nearbyDogCard
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(OPTheme.quickSpring, value: selectedDog?.id)
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
                            ZStack {
                                Circle()
                                    .fill(OPTheme.accentGradient)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: OPTheme.accent.opacity(0.4), radius: 6, y: 3)
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
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

    // MARK: - Walker Card

    private func walkerCard(_ walker: MapWalkerPin) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(OPTheme.accentGradient)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(walker.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(OPTheme.accent)
                    Text(String(format: "%.1f", walker.rating))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                    Text("·")
                    Text("\(walker.pricePerWalk) лв/разходка")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }

            Spacer()

            Button {
                showWalkerPayment = true
            } label: {
                Text("Плати")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(OPTheme.primaryGradient, in: Capsule())
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        .alert("Плащане", isPresented: $showWalkerPayment) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Функцията за плащане с карта ще бъде налична скоро. Ще можете да плащате директно на \(walker.name).")
        }
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
