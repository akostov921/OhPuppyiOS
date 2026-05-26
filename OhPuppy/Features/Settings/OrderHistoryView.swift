import SwiftUI

struct OrderHistoryView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if store.orders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bag")
                        .font(.system(size: 40))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Нямаш поръчки все още")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.orders.sorted(by: { $0.date > $1.date })) { order in
                        orderRow(order)
                    }
                }
                .padding(OPTheme.screenPadding)
            }
        }
        .background(OPTheme.bg)
        .navigationTitle("Поръчки")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func orderRow(_ order: Order) -> some View {
        let statusColor: Color = switch order.status {
        case .processing: OPTheme.warning
        case .shipped: OPTheme.sky
        case .delivered: OPTheme.success
        }

        return HStack(spacing: 12) {
            AsyncImage(url: URL(string: order.photoURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(order.productName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(1)
                Text(order.brandName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                HStack(spacing: 6) {
                    Circle().fill(statusColor).frame(width: 6, height: 6)
                    Text(order.status.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(statusColor)
                    if order.status != .processing {
                        Text(order.trackingNumber)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.2f лв", order.price))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                Text(order.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }
        }
        .padding(12)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }
}
