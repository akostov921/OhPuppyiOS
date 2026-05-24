import SwiftUI

// MARK: - Available Dog Statuses

let availableStatuses: [DogStatus] = [
    DogStatus(id: "walk", emoji: "🚶", label: "На разходка", color: .green),
    DogStatus(id: "sleep", emoji: "😴", label: "Спи", color: .purple),
    DogStatus(id: "eat", emoji: "🍖", label: "Яде", color: .orange),
    DogStatus(id: "vet", emoji: "🏥", label: "При ветеринаря", color: .red),
    DogStatus(id: "play", emoji: "🎾", label: "Играе", color: .mint),
    DogStatus(id: "train", emoji: "🎓", label: "Тренира", color: .blue),
    DogStatus(id: "groom", emoji: "🛁", label: "На гриминг", color: .cyan),
    DogStatus(id: "chill", emoji: "😎", label: "Релаксира", color: .yellow),
]

// MARK: - Story Viewer (Fullscreen)

struct StoryViewer: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let stories: [Story]
    @State private var currentIndex: Int

    @State private var progress: CGFloat = 0
    @State private var timer: Timer?

    init(stories: [Story], startIndex: Int = 0) {
        self.stories = stories
        self._currentIndex = State(initialValue: startIndex)
    }

    private var currentStory: Story {
        stories[min(currentIndex, stories.count - 1)]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Photo
            AsyncImage(url: currentStory.photoURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(Color(hex: "1A1A2E"))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea()

            // Tap zones
            HStack(spacing: 0) {
                // Left half - previous
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToPrevious() }

                // Right half - next
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToNext() }
            }

            // Top overlay
            VStack(spacing: 0) {
                // Progress bars
                HStack(spacing: 4) {
                    ForEach(0..<stories.count, id: \.self) { i in
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: i < currentIndex ? geo.size.width : (i == currentIndex ? geo.size.width * progress : 0))
                            }
                        }
                        .frame(height: 3)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                // Dog info + close button
                HStack(spacing: 10) {
                    // Small avatar
                    AsyncImage(url: currentStory.photoURL) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(Color.white.opacity(0.3))
                        }
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentStory.dogName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(currentStory.ownerName) \u{00B7} \(timeAgo(currentStory.timestamp))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.2), in: Circle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                Spacer()

                // Caption at bottom
                if !currentStory.caption.isEmpty {
                    Text(currentStory.caption)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: currentIndex) { _, _ in
            resetTimer()
            markCurrentAsSeen()
        }
        .statusBarHidden(true)
    }

    private func startTimer() {
        progress = 0
        markCurrentAsSeen()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            progress += 0.05 / 5.0 // 5 seconds total
            if progress >= 1.0 {
                goToNext()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        stopTimer()
        startTimer()
    }

    private func goToNext() {
        if currentIndex < stories.count - 1 {
            currentIndex += 1
        } else {
            dismiss()
        }
    }

    private func goToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            progress = 0
        }
    }

    private func markCurrentAsSeen() {
        store.markStorySeen(id: currentStory.id)
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "сега" }
        let minutes = seconds / 60
        if minutes < 60 { return "преди \(minutes) мин" }
        let hours = minutes / 60
        if hours < 24 { return "преди \(hours) ч" }
        return "преди \(hours / 24) д"
    }
}

// MARK: - Add Story Sheet

struct AddStorySheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var photoSelected = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Photo placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                        .fill(OPTheme.surfaceSunken)
                        .frame(height: 300)

                    if photoSelected {
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=600&h=900&q=85")) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(OPTheme.textTertiary)
                            Text("Натисни за снимка")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                    }
                }
                .onTapGesture {
                    withAnimation(OPTheme.quickSpring) {
                        photoSelected = true
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)

                // Caption field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Надпис")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    TextField("Какво прави кучето ти?", text: $caption)
                        .font(.system(size: 16, weight: .medium))
                        .padding(14)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, OPTheme.screenPadding)

                Spacer()

                // Share button
                Button {
                    store.addStory(caption: caption)
                    dismiss()
                } label: {
                    Text("Сподели")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            photoSelected ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                }
                .disabled(!photoSelected)
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 20)
            }
            .background(OPTheme.bg)
            .navigationTitle("Нова история")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
        }
    }
}
