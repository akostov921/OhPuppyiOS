import SwiftUI

enum OPTheme {
    // Primary — deep forest green
    static let primary = Color(hex: "1B4332")
    static let primaryLight = Color(hex: "2D6A4F")
    static let primarySoft = Color(hex: "D8F3DC")
    static let onPrimary = Color.white

    // Accent — warm amber/gold
    static let accent = Color(hex: "F4A261")
    static let accentDark = Color(hex: "E76F51")
    static let accentSoft = Color(hex: "FFF1E6")

    // Mint / Emerald
    static let mint = Color(hex: "52B788")
    static let mintSoft = Color(hex: "B7E4C7")

    // Rose
    static let rose = Color(hex: "E07A5F")
    static let roseSoft = Color(hex: "FCEAE5")

    // Sky
    static let sky = Color(hex: "457B9D")
    static let skySoft = Color(hex: "E3EEF5")

    // Semantic
    static let success = Color(hex: "40916C")
    static let successSoft = Color(hex: "D8F3DC")
    static let warning = Color(hex: "E9C46A")
    static let warningSoft = Color(hex: "FFF8E1")
    static let danger = Color(hex: "E63946")
    static let dangerSoft = Color(hex: "FFE5E7")
    static let info = Color(hex: "457B9D")
    static let infoSoft = Color(hex: "E3EEF5")

    // Surfaces — WHITE based
    static let bg = Color.white
    static let surface = Color.white
    static let surfaceSecondary = Color(hex: "F8F9FA")
    static let surfaceSunken = Color(hex: "F1F3F5")

    // Text
    static let text = Color(hex: "1A1A2E")
    static let textSecondary = Color(hex: "6C757D")
    static let textTertiary = Color(hex: "ADB5BD")

    // Borders
    static let border = Color(hex: "000000").opacity(0.06)
    static let borderStrong = Color(hex: "000000").opacity(0.12)

    // MARK: - Gradients

    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F"), Color(hex: "52B788")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [Color(hex: "F4A261"), Color(hex: "E76F51")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mintGradient = LinearGradient(
        colors: [Color(hex: "52B788"), Color(hex: "40916C")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [Color(hex: "F4A261"), Color(hex: "E9C46A")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let avatarRingGradient = AngularGradient(
        colors: [Color(hex: "52B788"), Color(hex: "2D6A4F"), Color(hex: "F4A261"), Color(hex: "E76F51"), Color(hex: "52B788")],
        center: .center
    )

    // MARK: - Animation Constants

    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let gentleSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)

    // MARK: - Dimensions

    static let cornerRadius: CGFloat = 24
    static let cornerRadiusSmall: CGFloat = 16
    static let cornerRadiusTiny: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
