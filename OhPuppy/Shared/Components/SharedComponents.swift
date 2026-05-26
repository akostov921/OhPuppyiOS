import SwiftUI

// MARK: - Dog Avatar with Gradient Ring

struct DogAvatar: View {
    let url: URL?
    var size: CGFloat = 56
    var showRing: Bool = true

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Circle().fill(OPTheme.surfaceSunken)
                    .overlay {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: size * 0.35))
                            .foregroundStyle(OPTheme.mint)
                    }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            if showRing {
                Circle()
                    .stroke(OPTheme.avatarRingGradient, lineWidth: size * 0.05)
                    .frame(width: size + size * 0.1, height: size + size * 0.1)
            }
        }
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let label: String
    var icon: String?
    var tone: Tone = .neutral

    enum Tone {
        case neutral, primary, accent, sage, warning, danger, info, rose, sky, success, mint

        var bg: Color {
            switch self {
            case .neutral: OPTheme.surfaceSunken
            case .primary: OPTheme.primarySoft
            case .accent: OPTheme.accentSoft
            case .sage: OPTheme.successSoft
            case .warning: OPTheme.warningSoft
            case .danger: OPTheme.dangerSoft
            case .info: OPTheme.infoSoft
            case .rose: OPTheme.roseSoft
            case .sky: OPTheme.skySoft
            case .success: OPTheme.successSoft
            case .mint: OPTheme.mintSoft
            }
        }

        var fg: Color {
            switch self {
            case .neutral: OPTheme.textSecondary
            case .primary: OPTheme.primary
            case .accent: OPTheme.accent
            case .sage: OPTheme.success
            case .warning: OPTheme.accent
            case .danger: OPTheme.danger
            case .info: OPTheme.info
            case .rose: OPTheme.rose
            case .sky: OPTheme.sky
            case .success: OPTheme.success
            case .mint: OPTheme.mint
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
            }
            Text(label)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(tone.fg)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tone.bg, in: Capsule())
    }
}

// MARK: - Section Header

struct OPSectionHeader: View {
    let title: String
    var action: (() -> Void)?
    var actionLabel: String = "Виж всичко"

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Spacer()
            if let action {
                Button(actionLabel) { action() }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Animated Card

struct OPCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(OPTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Pressable Card Modifier

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(OPTheme.quickSpring, value: configuration.isPressed)
    }
}

// MARK: - Gradient Card

struct GradientCard<Content: View>: View {
    var gradient: LinearGradient = OPTheme.primaryGradient
    var cornerRadius: CGFloat = OPTheme.cornerRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.2), radius: 16, y: 6)
    }
}

// MARK: - Wordmark with Gradient

struct OPWordmark: View {
    var size: CGFloat = 20

    var body: some View {
        HStack(spacing: size * 0.35) {
            Circle()
                .fill(OPTheme.primaryGradient)
                .frame(width: size * 1.6, height: size * 1.6)
                .overlay {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: size * 0.7))
                        .foregroundStyle(OPTheme.accent)
                        .symbolEffect(.breathe)
                }
                .shadow(color: OPTheme.primary.opacity(0.3), radius: 4, y: 2)
            (Text("Oh").font(.system(size: size * 1.3, weight: .bold)) +
             Text("Puppy").font(.system(size: size * 1.3, weight: .medium, design: .serif)).italic().foregroundColor(OPTheme.mint))
                .foregroundStyle(OPTheme.text)
                .tracking(-size * 0.03)
        }
    }
}

// MARK: - Loading Paw

struct LoadingPaw: View {
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: "pawprint.fill")
            .font(.system(size: size))
            .foregroundStyle(OPTheme.mintGradient)
            .symbolEffect(.variableColor.iterative)
    }
}

// MARK: - Playful Empty State Icon

struct PlayfulEmptyIcon: View {
    let icon: String
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size))
            .foregroundStyle(OPTheme.textTertiary)
            .symbolEffect(.wiggle.byLayer)
    }
}

// MARK: - Icon Badge

struct IconBadge: View {
    let icon: String
    var color: Color = OPTheme.mint
    var bgColor: Color = OPTheme.mintSoft
    var size: CGFloat = 44

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
            .fill(bgColor)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: icon)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(color)
            }
    }
}

// MARK: - Date formatting

extension Date {
    func formatted(as style: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "bg_BG")
        f.dateFormat = style
        return f.string(from: self)
    }

    var shortBG: String {
        formatted(as: "d MMM yyyy")
    }

    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: self)).day ?? 0
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

// MARK: - Back Button

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .symbolEffect(.bounce.down, value: appeared)
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 1))
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
