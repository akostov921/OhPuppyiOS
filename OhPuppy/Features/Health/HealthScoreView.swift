import SwiftUI

struct HealthScoreView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var animatedScore: Double = 0
    @State private var ringProgress: CGFloat = 0
    @State private var appeared = false

    private var dog: Dog {
        store.dogs.first { $0.id == dogId } ?? Dog(id: dogId, name: "?", breed: "", birthDate: .now, sex: .male, neutered: false, weight: 0, ownerId: "1")
    }

    private var score: Int {
        store.healthScore(for: dogId)
    }

    private var breakdown: [(category: String, score: Int, maxScore: Int, status: String)] {
        store.healthBreakdown(for: dogId)
    }

    private var scoreColor: Color {
        if score >= 80 { return OPTheme.success }
        if score >= 50 { return OPTheme.warning }
        return OPTheme.danger
    }

    private var scoreLabel: String {
        if score >= 80 { return "Отлично" }
        if score >= 50 { return "Добре" }
        return "Нуждае се от внимание"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 24) {
                scoreRing
                breakdownSection
                tipsSection
            }
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .background(OPTheme.bg)
        .navigationTitle("Здравен скор")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                ringProgress = CGFloat(score) / 100.0
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animatedScore = Double(score)
            }
            withAnimation(OPTheme.gentleSpring.delay(0.3)) {
                appeared = true
            }
        }
    }

    // MARK: - Score Ring

    private var scoreRing: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(OPTheme.surfaceSunken, lineWidth: 14)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        AngularGradient(
                            colors: [scoreColor.opacity(0.6), scoreColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(animatedScore))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                        .contentTransition(.numericText(value: animatedScore))
                    Text("/ 100")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }

            Text(scoreLabel)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(scoreColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(scoreColor.opacity(0.12), in: Capsule())
        }
        .padding(.top, 10)
    }

    // MARK: - Breakdown

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Разбивка")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
                .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 8) {
                ForEach(Array(breakdown.enumerated()), id: \.offset) { index, item in
                    NavigationLink(destination: destinationFor(index: index)) {
                        breakdownRow(item: item)
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    private func breakdownRow(item: (category: String, score: Int, maxScore: Int, status: String)) -> some View {
        HStack(spacing: 12) {
            statusIcon(for: item.status)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.category)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                Text("\(item.score)/\(item.maxScore) точки")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            progressBar(value: CGFloat(item.score), max: CGFloat(item.maxScore), status: item.status)
                .frame(width: 60, height: 6)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func statusIcon(for status: String) -> some View {
        switch status {
        case "good":
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(OPTheme.success)
        case "warning":
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundStyle(OPTheme.warning)
        default:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(OPTheme.danger)
        }
    }

    private func progressBar(value: CGFloat, max: CGFloat, status: String) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(OPTheme.surfaceSunken)
                Capsule()
                    .fill(status == "good" ? OPTheme.success : status == "warning" ? OPTheme.warning : OPTheme.danger)
                    .frame(width: geo.size.width * (value / max))
            }
        }
    }

    @ViewBuilder
    private func destinationFor(index: Int) -> some View {
        switch index {
        case 0: VaccineListView(dogId: dogId)
        case 1: WeightView(dogId: dogId)
        case 2: VetVisitsView(dogId: dogId)
        case 3: GroomingView(dogId: dogId)
        case 4: MedicationsView(dogId: dogId)
        default: EmptyView()
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Съвети за подобрение")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
                .padding(.horizontal, OPTheme.screenPadding)

            let tips = generateTips()
            if tips.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.success)
                    Text("Всичко е наред! Продължавай в същия дух.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(OPTheme.successSoft, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                .padding(.horizontal, OPTheme.screenPadding)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in
                        NavigationLink(destination: tip.destination) {
                            HStack(spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(OPTheme.warning)
                                Text(tip.text)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(OPTheme.text)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                            .padding(14)
                            .background(OPTheme.warningSoft, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous))
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    private struct Tip: Identifiable {
        let id = UUID()
        let text: String
        let destination: AnyView
    }

    private func generateTips() -> [Tip] {
        var tips: [Tip] = []
        let now = Date()

        // Check overdue vaccines
        let vaccines = store.vaccinesFor(dogId: dogId)
        let overdueVaccines = vaccines.filter { v in
            guard let due = v.nextDueDate else { return false }
            return due < now
        }
        for v in overdueVaccines.prefix(2) {
            if let due = v.nextDueDate {
                let days = Calendar.current.dateComponents([.day], from: due, to: now).day ?? 0
                tips.append(Tip(
                    text: "Ваксината за \(v.type.label) е просрочена с \(days) дни",
                    destination: AnyView(VaccineListView(dogId: dogId))
                ))
            }
        }

        // Check vet visit recency
        let visits = store.vetVisitsFor(dogId: dogId)
        if let lastVisit = visits.first {
            let months = Calendar.current.dateComponents([.month], from: lastVisit.date, to: now).month ?? 0
            if months > 6 {
                tips.append(Tip(
                    text: "Не сте посещавали ветеринар от \(months) месеца",
                    destination: AnyView(VetVisitsView(dogId: dogId))
                ))
            }
        } else {
            tips.append(Tip(
                text: "Няма записани ветеринарни посещения",
                destination: AnyView(VetVisitsView(dogId: dogId))
            ))
        }

        // Check grooming
        let groomLogs = store.groomingFor(dogId: dogId)
        if let lastGroom = groomLogs.first {
            let days = Calendar.current.dateComponents([.day], from: lastGroom.date, to: now).day ?? 0
            if days > 30 {
                tips.append(Tip(
                    text: "Последният гриминг беше преди \(days) дни",
                    destination: AnyView(GroomingView(dogId: dogId))
                ))
            }
        } else {
            tips.append(Tip(
                text: "Няма записани гриминг сесии",
                destination: AnyView(GroomingView(dogId: dogId))
            ))
        }

        // Check weight
        let breedRange = breedWeightRange(for: dog.breed)
        let lowerBound = breedRange.0 * 0.85
        let upperBound = breedRange.1 * 1.15
        if dog.weight < lowerBound || dog.weight > upperBound {
            tips.append(Tip(
                text: "Теглото (\(String(format: "%.1f", dog.weight)) кг) е извън нормата за породата",
                destination: AnyView(WeightView(dogId: dogId))
            ))
        }

        return tips
    }
}

// MARK: - Breed Weight Range Helper

private func breedWeightRange(for breed: String) -> (Double, Double) {
    switch breed {
    case "Лабрадор": return (25.0, 36.0)
    case "Френски булдог": return (8.0, 14.0)
    case "Голдън ретривър": return (25.0, 34.0)
    default: return (5.0, 40.0)
    }
}
