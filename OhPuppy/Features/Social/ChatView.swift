import SwiftUI

struct ChatView: View {
    @Environment(AppStore.self) private var store
    @State private var searchText = ""
    @State private var selectedChat: ChatPreview?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Съобщения")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        DogStatusEmoji()
                    }
                    Text("5 разговора")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .foregroundStyle(OPTheme.textTertiary)
                    TextField("Търси...", text: $searchText)
                        .font(.system(size: 15, weight: .medium))
                }
                .padding(12)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 16)

                // Chat rows
                VStack(spacing: 0) {
                    ForEach(Array(chatData.enumerated()), id: \.element.name) { index, chat in
                        NavigationLink(destination: ChatRoomView(chat: chat)) {
                            chatRow(chat)
                        }
                        .buttonStyle(.plain)

                        if index < chatData.count - 1 {
                            Divider().padding(.leading, 76)
                        }
                    }
                }
                .background(OPTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                        .stroke(OPTheme.border, lineWidth: 1)
                )
                .shadow(color: OPTheme.primary.opacity(0.04), radius: 10, y: 4)
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationTitle("Съобщения")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chatRow(_ chat: ChatPreview) -> some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                if chat.isGroup {
                    ZStack {
                        Circle().fill(OPTheme.primaryGradient)
                            .frame(width: 50, height: 50)
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    }
                } else {
                    AsyncImage(url: URL(string: chat.avatarURL)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                }

                // Online indicator
                if chat.isOnline {
                    Circle()
                        .fill(OPTheme.success)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                        .frame(width: 50, height: 50, alignment: .bottomTrailing)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.system(size: 15, weight: chat.unread > 0 ? .bold : .semibold))
                        .foregroundStyle(OPTheme.text)
                    Spacer()
                    Text(chat.time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(chat.unread > 0 ? OPTheme.mint : OPTheme.textTertiary)
                }
                HStack {
                    Text(chat.lastMessage)
                        .font(.system(size: 13, weight: chat.unread > 0 ? .semibold : .regular))
                        .foregroundStyle(chat.unread > 0 ? OPTheme.text : OPTheme.textSecondary)
                        .lineLimit(1)
                    Spacer()
                    if chat.unread > 0 {
                        Text("\(chat.unread)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(OPTheme.primaryGradient, in: Circle())
                            .overlay {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(OPTheme.primary)
                                    .symbolEffect(.pulse.byLayer)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .offset(x: 2, y: -2)
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Data

    private var chatData: [ChatPreview] {
        [
            ChatPreview(name: "Петър (Тоби)", avatarURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&h=100&q=85", lastMessage: "Утре в парка ли си?", time: "14:32", unread: 2, isOnline: true, isGroup: false),
            ChatPreview(name: "Разходка Борисова", avatarURL: "", lastMessage: "Мария: Аз ще дойда с Рекс в 17:00", time: "12:15", unread: 5, isOnline: false, isGroup: true),
            ChatPreview(name: "Ана (Мила)", avatarURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&h=100&q=85", lastMessage: "Супер е новата каишка!", time: "вчера", unread: 0, isOnline: true, isGroup: false),
            ChatPreview(name: "Д-р Иванов", avatarURL: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=100&h=100&q=85", lastMessage: "Резултатите от изследванията са готови", time: "вчера", unread: 1, isOnline: false, isGroup: false),
            ChatPreview(name: "Марко (Чарли)", avatarURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&h=100&q=85", lastMessage: "Благодаря за съвета!", time: "пон.", unread: 0, isOnline: false, isGroup: false),
        ]
    }
}

// MARK: - ChatPreview Model

struct ChatPreview: Hashable {
    let name: String
    let avatarURL: String
    let lastMessage: String
    let time: String
    let unread: Int
    let isOnline: Bool
    let isGroup: Bool
}

// MARK: - Chat Room View

struct ChatRoomView: View {
    let chat: ChatPreview
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            chatBubble(message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 10) {
                TextField("Напиши съобщение...", text: $inputText)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(OPTheme.surfaceSunken, in: Capsule())

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(inputText.isEmpty ? OPTheme.textTertiary : OPTheme.mint)
                }
                .disabled(inputText.isEmpty)
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.vertical, 10)
            .background(OPTheme.surface)
            .overlay(alignment: .top) {
                Divider()
            }
        }
        .background(OPTheme.bg)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        if !chat.isGroup {
                            AsyncImage(url: URL(string: chat.avatarURL)) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    Circle().fill(OPTheme.surfaceSunken)
                                }
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        }
                        Text(chat.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                    }
                }
                .foregroundStyle(OPTheme.primary)
            }
        }
        .onAppear {
            loadMockMessages()
        }
    }

    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isMine { Spacer(minLength: 60) }
            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(message.isMine ? .white : OPTheme.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isMine ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                Text(message.time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            if !message.isMine { Spacer(minLength: 60) }
        }
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let newMsg = ChatMessage(
            id: UUID().uuidString,
            text: inputText,
            time: formatter.string(from: Date()),
            isMine: true
        )
        messages.append(newMsg)
        let sentText = inputText
        inputText = ""

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(Double.random(in: 1.5...3.0)))
            let replies = [
                "Супер! \u{1F44D}",
                "Добре, разбрах!",
                "Хаха, да! \u{1F602}",
                "Ще помисля и ще ти пиша.",
                "Страхотно! Кога ти е удобно?",
                "Рекс също ще се радва!",
                "Идеално, чудесна идея!",
                "\u{1F43E} Чудесно!",
            ]
            let reply = ChatMessage(
                id: UUID().uuidString,
                text: replies.randomElement() ?? "OK!",
                time: formatter.string(from: Date()),
                isMine: false
            )
            withAnimation { messages.append(reply) }
        }
    }

    private func loadMockMessages() {
        messages = [
            ChatMessage(id: "m1", text: "Здравей! Как е \(chat.isGroup ? "групата" : "кучето")?", time: "10:15", isMine: false),
            ChatMessage(id: "m2", text: "Здравей! Супер е, току-що се върнахме от разходка", time: "10:18", isMine: true),
            ChatMessage(id: "m3", text: "Къде ходихте? В Борисова?", time: "10:20", isMine: false),
            ChatMessage(id: "m4", text: "Да, в Борисова. Има много кучета днес!", time: "10:22", isMine: true),
            ChatMessage(id: "m5", text: "Готино! Може утре да дойдем и ние", time: "10:25", isMine: false),
            ChatMessage(id: "m6", text: "Да, ще бъде супер! В колко часа?", time: "10:27", isMine: true),
        ]
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let time: String
    let isMine: Bool
}
