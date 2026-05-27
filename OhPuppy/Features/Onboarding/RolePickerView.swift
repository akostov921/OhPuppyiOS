import SwiftUI

struct RolePickerView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedRoles: Set<UserRole> = []
    @State private var pawFloat: CGFloat = 0

    private let roles: [(role: UserRole, desc: String, color: Color, gradient: LinearGradient)] = [
        (.owner, "Следи здравето и ежедневието на кучето си", OPTheme.mint, OPTheme.primaryGradient),
        (.vet, "Управлявай клиника, пациенти и часове", OPTheme.sky, OPTheme.mintGradient),
        (.walker, "Разхождай кучета и печели от това", OPTheme.accent, LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing)),
        (.brand, "Продавай продукти и храна за кучета", OPTheme.rose, OPTheme.accentGradient),
        (.shelter, "Намери дом за изоставени животни", OPTheme.accentDark, LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing)),
    ]

    var body: some View {
        ZStack {
            OPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(OPTheme.primaryGradient)
                    .offset(y: pawFloat)
                    .padding(.bottom, 16)

                Text("Добре дошъл в")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)

                Text("OhPuppy")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                    .padding(.bottom, 6)

                Text("Кой си ти?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
                    .padding(.bottom, 4)

                Text("Можеш да избереш повече от едно.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .padding(.bottom, 24)

                VStack(spacing: 10) {
                    ForEach(roles, id: \.role) { item in
                        let isSelected = selectedRoles.contains(item.role)

                        Button {
                            withAnimation(OPTheme.quickSpring) {
                                if selectedRoles.contains(item.role) {
                                    selectedRoles.remove(item.role)
                                } else {
                                    selectedRoles.insert(item.role)
                                }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: item.role.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 42, height: 42)
                                    .background(item.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.role.label)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(OPTheme.text)
                                    Text(item.desc)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(OPTheme.textSecondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(isSelected ? OPTheme.mint : OPTheme.textTertiary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                isSelected ? OPTheme.mintSoft.opacity(0.35) : OPTheme.surfaceSecondary.opacity(0.5),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(isSelected ? OPTheme.mint.opacity(0.4) : OPTheme.border.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)

                Spacer()

                Button {
                    guard !selectedRoles.isEmpty else { return }
                    let primary = selectedRoles.contains(.owner) ? UserRole.owner : selectedRoles.first!
                    store.activeRole = primary
                    for role in selectedRoles where role != .owner {
                        store.registerRole(role)
                    }
                    withAnimation(OPTheme.springAnimation) {
                        store.hasSelectedInitialRole = true
                    }
                } label: {
                    Text("Продължи")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            !selectedRoles.isEmpty ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.textTertiary.opacity(0.4)),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: !selectedRoles.isEmpty ? OPTheme.primary.opacity(0.25) : .clear, radius: 10, y: 4)
                }
                .disabled(selectedRoles.isEmpty)
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pawFloat = -8
            }
        }
    }
}
