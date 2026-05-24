import SwiftUI
import Charts

struct WeightView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddWeight = false

    private var dog: Dog? { store.dogs.first { $0.id == dogId } }
    private var weights: [WeightLog] { store.weightsFor(dogId: dogId) }
    private var lastWeight: WeightLog? { weights.last }
    private var prevWeight: WeightLog? { weights.count >= 2 ? weights[weights.count - 2] : nil }
    private var diff: Double { (lastWeight?.weight ?? 0) - (prevWeight?.weight ?? 0) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                chartCard
                growthChartLink
                historySection
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Тегло")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(OPTheme.springAnimation) {
                        showAddWeight = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: showAddWeight)
                        .frame(width: 34, height: 34)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showAddWeight) {
            AddWeightSheet(dogId: dogId)
        }
    }

    // MARK: - Chart Card

    @State private var chartAppeared = false

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ТЕКУЩО ТЕГЛО")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", lastWeight?.weight ?? dog?.weight ?? 0))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("кг")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }
                Spacer()
                StatPill(
                    label: "\(diff > 0 ? "+" : "")\(String(format: "%.1f", diff)) кг",
                    icon: diff > 0 ? "arrow.up.right" : diff < 0 ? "arrow.down.right" : "minus",
                    tone: diff > 0 ? .mint : diff < 0 ? .warning : .neutral
                )
            }

            if weights.count > 1 {
                Chart(weights) { w in
                    AreaMark(
                        x: .value("Дата", w.date),
                        y: .value("Тегло", w.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [OPTheme.mint.opacity(0.3), OPTheme.mint.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Дата", w.date),
                        y: .value("Тегло", w.weight)
                    )
                    .foregroundStyle(OPTheme.mint)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Дата", w.date),
                        y: .value("Тегло", w.weight)
                    )
                    .foregroundStyle(w.id == weights.last?.id ? OPTheme.primary : OPTheme.mint)
                    .symbolSize(w.id == weights.last?.id ? 70 : 35)
                    .annotation(position: .top, spacing: 6) {
                        if w.id == weights.last?.id {
                            Text(String(format: "%.1f", w.weight))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(OPTheme.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(OPTheme.primarySoft, in: Capsule())
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(as: "MMM"))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 150)
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
        .opacity(chartAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                chartAppeared = true
            }
        }
    }

    // MARK: - Growth Chart Link

    private var growthChartLink: some View {
        NavigationLink(destination: GrowthChartView(dogId: dogId)) {
            HStack(spacing: 12) {
                IconBadge(icon: "chart.line.uptrend.xyaxis", color: OPTheme.accent, bgColor: OPTheme.accentSoft, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ръст спрямо породата")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                    Text("Сравни с породния стандарт")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            .padding(14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "История")

            VStack(spacing: 0) {
                ForEach(Array(weights.reversed().enumerated()), id: \.element.id) { index, w in
                    HStack(spacing: 12) {
                        IconBadge(icon: "scalemass.fill", color: OPTheme.accent, bgColor: OPTheme.accentSoft, size: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(String(format: "%.1f", w.weight)) кг")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text(w.date.shortBG)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        Spacer()

                        if index == 0 {
                            Text("Последно")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(OPTheme.mint)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(OPTheme.mintSoft, in: Capsule())
                        }
                    }
                    .padding(14)

                    if index < weights.count - 1 {
                        Divider().padding(.leading, 66)
                    }
                }
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
        }
    }
}

// MARK: - Add Weight Sheet

struct AddWeightSheet: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var weight = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ТЕГЛО (КГ)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    TextField("14.2", text: $weight)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                        .keyboardType(.decimalPad)
                        .padding(16)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ДАТА")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .tint(OPTheme.primary)
                }

                Spacer()
            }
            .padding(OPTheme.screenPadding)
            .background(OPTheme.bg)
            .navigationTitle("Ново тегло")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        if let w = Double(weight) {
                            withAnimation(OPTheme.springAnimation) {
                                store.addWeight(WeightLog(id: store.newId(), dogId: dogId, weight: w, date: date))
                            }
                        }
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                    .disabled(Double(weight) == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
