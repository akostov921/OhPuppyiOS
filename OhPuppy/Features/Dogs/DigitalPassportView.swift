import SwiftUI
import CoreImage.CIFilterBuiltins

struct DigitalPassportView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showSaveConfirmation = false

    private var dog: Dog {
        store.dogs.first { $0.id == dogId } ?? Dog(id: dogId, name: "?", breed: "", birthDate: .now, sex: .male, neutered: false, weight: 0, ownerId: "1")
    }

    private var qrDataString: String {
        let vaccines = store.vaccinesFor(dogId: dogId)
        let vaccinesSummary = vaccines.prefix(3).map { $0.type.label }.joined(separator: ", ")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let data: [String: Any] = [
            "name": dog.name,
            "breed": dog.breed,
            "birthDate": dateFormatter.string(from: dog.birthDate),
            "weight": dog.weight,
            "microchip": dog.microchip ?? "N/A",
            "vaccinesSummary": vaccinesSummary,
            "allergies": "Няма известни",
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }

    private var qrImage: UIImage? {
        generateQRCode(from: qrDataString)
    }

    private var lastVaccineInfo: String {
        let vaccines = store.vaccinesFor(dogId: dogId)
            .sorted { $0.dateAdministered > $1.dateAdministered }
        guard let last = vaccines.first else { return "Няма данни" }
        return "\(last.type.label) — \(last.dateAdministered.shortBG)"
    }

    private var nextVaccineInfo: String {
        if let next = store.nextDueVaccine(dogId: dogId), let due = next.nextDueDate {
            return "\(next.type.label) — \(due.shortBG)"
        }
        return "Няма планирана"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                passportCard
                medicalSummary
            }
            .padding(.bottom, 60)
        }
        .background(OPTheme.bg)
        .navigationTitle("Дигитален паспорт")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Запазено!", isPresented: $showSaveConfirmation) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text("QR кодът е запазен в снимките ти.")
        }
    }

    // MARK: - Passport Card

    private var passportCard: some View {
        VStack(spacing: 20) {
            // Header with dog info
            HStack(spacing: 14) {
                AsyncImage(url: dog.avatarURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(OPTheme.surfaceSunken)
                            .overlay {
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(OPTheme.mint)
                            }
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 2))

                VStack(alignment: .leading, spacing: 4) {
                    Text(dog.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("\(dog.breed) \u{2022} \(dog.age)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(OPTheme.success)
            }

            // QR Code
            if let qrImg = qrImage {
                Image(uiImage: qrImg)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(OPTheme.border, lineWidth: 1)
                    )
            }

            Text("Сканирай за медицинска информация")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)

            // Action buttons
            HStack(spacing: 12) {
                if let qrImg = qrImage {
                    ShareLink(item: Image(uiImage: qrImg), preview: SharePreview("QR паспорт на \(dog.name)", image: Image(uiImage: qrImg))) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Сподели")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(OPTheme.primaryGradient, in: Capsule())
                    }
                }

                Button {
                    showSaveConfirmation = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Запази като снимка")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(OPTheme.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(OPTheme.primarySoft, in: Capsule())
                }
            }
        }
        .padding(20)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
        .padding(.horizontal, OPTheme.screenPadding)
        .padding(.top, 20)
    }

    // MARK: - Medical Summary

    private var medicalSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Медицинска информация")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            VStack(spacing: 0) {
                passportRow(label: "Име", value: dog.name, isFirst: true)
                passportRow(label: "Порода", value: dog.breed)
                passportRow(label: "Дата на раждане", value: dog.birthDate.shortBG)
                passportRow(label: "Тегло", value: "\(String(format: "%.1f", dog.weight)) кг")
                passportRow(label: "Микрочип", value: dog.microchip ?? "Не е регистриран")
                passportRow(label: "Последна ваксина", value: lastVaccineInfo)
                passportRow(label: "Следваща ваксина", value: nextVaccineInfo)
                passportRow(label: "Алергии", value: "Няма известни", isLast: true)
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
        }
        .padding(.horizontal, OPTheme.screenPadding)
        .padding(.top, 24)
    }

    private func passportRow(label: String, value: String, isFirst: Bool = false, isLast: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.textSecondary)
                    .frame(width: 130, alignment: .leading)
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if !isLast {
                Divider().padding(.leading, 16)
            }
        }
    }

    // MARK: - QR Generation

    private func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        return UIImage(ciImage: scaledImage)
    }
}
