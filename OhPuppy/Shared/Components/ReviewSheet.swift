import SwiftUI

struct ReviewSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let businessType: BusinessReview.BusinessType
    let businessId: String
    let businessName: String

    @State private var rating = 0
    @State private var comment = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: businessIcon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(businessColor)
                    Text(businessName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                }
                .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Как оценяваш?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                withAnimation(OPTheme.quickSpring) { rating = star }
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 32))
                                    .foregroundStyle(star <= rating ? OPTheme.accent : OPTheme.textTertiary)
                            }
                            .sensoryFeedback(.impact(flexibility: .soft), trigger: rating)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Коментар")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                    TextField("Сподели впечатленията си...", text: $comment, axis: .vertical)
                        .font(.system(size: 15))
                        .lineLimit(3...6)
                        .padding(12)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Spacer()

                Button {
                    let review = BusinessReview(
                        id: store.newId(),
                        businessType: businessType,
                        businessId: businessId,
                        reviewerName: store.ownerName,
                        rating: rating,
                        comment: comment,
                        date: Date()
                    )
                    store.addBusinessReview(review)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "star.bubble.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Изпрати ревю")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        rating > 0 ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.textTertiary.opacity(0.4)),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
                .disabled(rating == 0)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .background(OPTheme.bg)
            .navigationTitle("Остави ревю")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Затвори") { dismiss() }
                }
            }
        }
    }

    private var businessIcon: String {
        switch businessType {
        case .vet: "stethoscope"
        case .brand: "bag.fill"
        case .walker: "figure.walk"
        case .shelter: "building.2.fill"
        }
    }

    private var businessColor: Color {
        switch businessType {
        case .vet: OPTheme.mint
        case .brand: OPTheme.accent
        case .walker: OPTheme.sky
        case .shelter: OPTheme.rose
        }
    }
}
