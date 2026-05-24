import SwiftUI
import Charts

struct GrowthChartView: View {
    let dogId: String
    @Environment(AppStore.self) private var store

    private var dog: Dog? { store.dogs.first { $0.id == dogId } }
    private var weights: [WeightLog] { store.weightsFor(dogId: dogId) }

    // MARK: - Breed Weight Data

    static let breedWeights: [String: [(months: Int, kg: Double)]] = [
        "Лабрадор": [(2, 8), (4, 15), (6, 22), (8, 27), (10, 29), (12, 30), (18, 31), (24, 32)],
        "Френски булдог": [(2, 3), (4, 5), (6, 7), (8, 9), (10, 10), (12, 11), (18, 12), (24, 12.5)],
        "Голдън ретривър": [(2, 7), (4, 14), (6, 21), (8, 26), (10, 28), (12, 30), (18, 32), (24, 34)],
    ]

    private var breedData: [(months: Int, kg: Double)]? {
        guard let breed = dog?.breed else { return nil }
        return Self.breedWeights[breed]
    }

    private var adultWeight: Double? {
        breedData?.last?.kg
    }

    private var currentWeight: Double {
        dog?.weight ?? 0
    }

    private var ageInMonths: Int {
        guard let birthDate = dog?.birthDate else { return 0 }
        return Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
    }

    private var expectedWeightAtAge: Double? {
        guard let data = breedData else { return nil }
        // Interpolate
        if ageInMonths <= (data.first?.months ?? 0) { return data.first?.kg }
        if ageInMonths >= (data.last?.months ?? 0) { return data.last?.kg }
        for i in 0..<data.count - 1 {
            if ageInMonths >= data[i].months && ageInMonths <= data[i + 1].months {
                let ratio = Double(ageInMonths - data[i].months) / Double(data[i + 1].months - data[i].months)
                return data[i].kg + ratio * (data[i + 1].kg - data[i].kg)
            }
        }
        return data.last?.kg
    }

    private var statusText: String {
        guard let expected = expectedWeightAtAge else { return "Няма данни" }
        let diff = currentWeight - expected
        let tolerance = expected * 0.1
        if abs(diff) <= tolerance { return "В нормата" }
        if diff > 0 { return "Над нормата" }
        return "Под нормата"
    }

    private var statusTone: StatPill.Tone {
        guard let expected = expectedWeightAtAge else { return .neutral }
        let diff = currentWeight - expected
        let tolerance = expected * 0.1
        if abs(diff) <= tolerance { return .success }
        if diff > 0 { return .warning }
        return .info
    }

    private var progressPercent: Double {
        guard let adult = adultWeight, adult > 0 else { return 0 }
        return min(1.0, currentWeight / adult)
    }

    // MARK: - Chart Data Points

    struct ChartPoint: Identifiable {
        let id = UUID()
        let months: Int
        let kg: Double
        let series: String
    }

    private var chartPoints: [ChartPoint] {
        var points: [ChartPoint] = []

        // Breed standard line
        if let data = breedData {
            for d in data {
                points.append(ChartPoint(months: d.months, kg: d.kg, series: "Стандарт"))
            }
        }

        // Actual weight data
        guard let birthDate = dog?.birthDate else { return points }
        let cal = Calendar.current
        for w in weights {
            let months = cal.dateComponents([.month], from: birthDate, to: w.date).month ?? 0
            points.append(ChartPoint(months: max(0, months), kg: w.weight, series: "Реално"))
        }

        return points
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                statusCard
                chartCard
                progressCard
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Ръст спрямо породата")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Status Card

    private var statusCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("СТАТУС")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(OPTheme.textSecondary)
                    .tracking(0.5)
                HStack(spacing: 8) {
                    Text(statusText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    StatPill(
                        label: "\(String(format: "%.1f", currentWeight)) кг",
                        icon: "scalemass.fill",
                        tone: statusTone
                    )
                }
                if let expected = expectedWeightAtAge {
                    Text("Очаквано за \(ageInMonths) м.: \(String(format: "%.1f", expected)) кг")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }
            Spacer()
        }
        .padding(OPTheme.cardPadding + 4)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("РЪСТ ВЪВ ВРЕМЕТО")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)

            if !chartPoints.isEmpty {
                Chart(chartPoints) { point in
                    if point.series == "Стандарт" {
                        LineMark(
                            x: .value("Месец", point.months),
                            y: .value("Тегло", point.kg)
                        )
                        .foregroundStyle(OPTheme.textTertiary)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .interpolationMethod(.catmullRom)
                    } else {
                        LineMark(
                            x: .value("Месец", point.months),
                            y: .value("Тегло", point.kg)
                        )
                        .foregroundStyle(OPTheme.accent)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Месец", point.months),
                            y: .value("Тегло", point.kg)
                        )
                        .foregroundStyle(OPTheme.accent)
                        .symbolSize(40)
                    }
                }
                .chartForegroundStyleScale([
                    "Стандарт": OPTheme.textTertiary,
                    "Реално": OPTheme.accent,
                ])
                .chartLegend(position: .bottom, spacing: 12)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6)) { value in
                        AxisValueLabel {
                            if let months = value.as(Int.self) {
                                Text("\(months)м")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel {
                            if let kg = value.as(Double.self) {
                                Text("\(Int(kg))")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    }
                }
                .frame(height: 220)
            }
        }
        .padding(OPTheme.cardPadding + 4)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ПРОГРЕС КЪМ ВЪЗРАСТНО ТЕГЛО")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(OPTheme.surfaceSunken)
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(OPTheme.warmGradient)
                        .frame(width: geo.size.width * progressPercent, height: 12)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(Int(progressPercent * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
                if let adult = adultWeight {
                    Text("\(String(format: "%.1f", currentWeight)) / \(String(format: "%.0f", adult)) кг")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }

            if let breed = dog?.breed, adultWeight != nil {
                Text("\(dog?.name ?? "") е \(Int(progressPercent * 100))% от очакваното тегло на възрастен \(breed.lowercased())")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(OPTheme.cardPadding + 4)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
    }
}
