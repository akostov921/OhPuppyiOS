import SwiftUI

struct FeedView: View {
    @State private var selectedTab = "Следвани"
    @State private var showCameraConfirmation = false

    private let tabs = ["Следвани", "За теб", "Близо"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                feedHeader
                    .padding(.bottom, 16)

                // Posts
                ForEach(feedPosts) { post in
                    FeedPostCard(post: post)
                        .padding(.bottom, 20)
                }
            }
            .padding(.top, 6)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .alert("Готово!", isPresented: $showCameraConfirmation) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text("Снимката е добавена!")
        }
    }

    // MARK: - Header

    private var feedHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                (Text("Любими ")
                    .font(.system(size: 28, weight: .bold))
                 + Text("хора")
                    .font(.system(size: 28, weight: .bold, design: .serif)).italic()
                    .foregroundColor(OPTheme.mint))
                    .foregroundStyle(OPTheme.text)

                Spacer()

                Button { showCameraConfirmation = true } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(OPTheme.accentGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: OPTheme.accent.opacity(0.3), radius: 6, y: 3)
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)

            // Tab strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            withAnimation(OPTheme.quickSpring) { selectedTab = tab }
                        } label: {
                            Text(tab)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(selectedTab == tab ? .white : OPTheme.text)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 9)
                                .background(
                                    selectedTab == tab ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                    in: Capsule()
                                )
                                .shadow(color: selectedTab == tab ? OPTheme.mint.opacity(0.3) : .clear, radius: 4, y: 2)
                        }
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Mock Data

    private var feedPosts: [FeedPost] {
        [
            FeedPost(
                id: "1",
                dogName: "Тоби",
                dogBreed: "бордър коли",
                ownerName: "Стефан",
                timeAgo: "2 ч.",
                photoID: "1450778869180-41d0601e046e",
                caption: "Първи плувен ден за сезона! \u{1F30A}",
                likes: 24,
                comments: 5,
                isLiked: true,
                avatarURL: "https://images.unsplash.com/photo-1551717743-49959800b1f6?auto=format&fit=crop&w=200&h=200&q=85"
            ),
            FeedPost(
                id: "2",
                dogName: "Локи",
                dogBreed: "френски булдог",
                ownerName: "Гери",
                timeAgo: "5 ч.",
                photoID: "1583511655857-d19b40a7a54e",
                caption: "Спи след дълга разходка из Витоша",
                likes: 18,
                comments: 2,
                isLiked: false,
                avatarURL: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=200&h=200&q=85"
            ),
            FeedPost(
                id: "3",
                dogName: "Мила",
                dogBreed: "корги",
                ownerName: "Дези",
                timeAgo: "8 ч.",
                photoID: "1612536057832-2ff7ead58194",
                caption: "Нов шампоан, нов живот \u{1F9F4}",
                likes: 31,
                comments: 8,
                isLiked: false,
                avatarURL: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=200&h=200&q=85"
            ),
        ]
    }
}

// MARK: - Feed Post Model

struct FeedPost: Identifiable {
    let id: String
    let dogName: String
    let dogBreed: String
    let ownerName: String
    let timeAgo: String
    let photoID: String
    let caption: String
    let likes: Int
    let comments: Int
    let isLiked: Bool
    let avatarURL: String

    var photoURL: URL? {
        URL(string: "https://images.unsplash.com/photo-\(photoID)?auto=format&fit=crop&w=800&h=800&q=85")
    }
}

// MARK: - Comment Model

struct FeedComment: Identifiable {
    let id: String
    let author: String
    let text: String
    let timeAgo: String
}

// MARK: - Feed Post Card

struct FeedPostCard: View {
    let post: FeedPost
    @State private var liked: Bool = false
    @State private var likeCount: Int = 0
    @State private var bookmarked: Bool = false
    @State private var showCommentSheet = false
    @State private var showMoreActions = false
    @State private var postHidden = false
    @State private var commentTapped = false
    @State private var showDogProfile = false

    private var matchingNearbyDog: NearbyDog? {
        nearbyDogsData.first { $0.name == post.dogName }
    }

    var body: some View {
        if postHidden {
            EmptyView()
        } else {
            postContent
        }
    }

    private var postContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Button {
                    if matchingNearbyDog != nil {
                        showDogProfile = true
                    }
                } label: {
                    DogAvatar(url: URL(string: post.avatarURL), size: 40, showRing: true)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Button {
                            if matchingNearbyDog != nil {
                                showDogProfile = true
                            }
                        } label: {
                            Text(post.dogName)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                        }
                        Text("\u{00B7}")
                            .foregroundStyle(OPTheme.textTertiary)
                        Text(post.dogBreed)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    Text("\(post.ownerName) \u{00B7} \(post.timeAgo)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }

                Spacer()

                Button { showMoreActions = true } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.vertical, 10)

            // Photo
            AsyncImage(url: post.photoURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .clipped()
                default:
                    Rectangle()
                        .fill(OPTheme.surfaceSunken)
                        .frame(height: 360)
                        .overlay {
                            ProgressView()
                                .tint(OPTheme.mint)
                        }
                }
            }

            // Action bar
            HStack(spacing: 18) {
                Button {
                    withAnimation(OPTheme.quickSpring) {
                        liked.toggle()
                        likeCount += liked ? 1 : -1
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(liked ? OPTheme.danger : OPTheme.text)
                            .symbolEffect(.bounce, value: liked)
                        Text("\(likeCount)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                    }
                }

                Button {
                    commentTapped.toggle()
                    showCommentSheet = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                            .symbolEffect(.wiggle, value: commentTapped)
                        Text("\(post.comments)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                    }
                }

                ShareLink(item: "\(post.dogName): \(post.caption)") {
                    Image(systemName: "paperplane")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                }

                Spacer()

                Button {
                    withAnimation(OPTheme.quickSpring) { bookmarked.toggle() }
                } label: {
                    Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(bookmarked ? OPTheme.accent : OPTheme.text)
                }
                .sensoryFeedback(.impact, trigger: bookmarked)
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.vertical, 10)

            // Caption
            VStack(alignment: .leading, spacing: 6) {
                (Text(post.dogName)
                    .font(.system(size: 14, weight: .bold))
                 + Text(" \(post.caption)")
                    .font(.system(size: 14, weight: .regular)))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(2)

                if post.comments > 0 {
                    Button { showCommentSheet = true } label: {
                        Text("Виж всички \(post.comments) коментара")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 12)
        }
        .onAppear {
            liked = post.isLiked
            likeCount = post.likes
        }
        .sensoryFeedback(.impact, trigger: liked)
        .sheet(isPresented: $showCommentSheet) {
            CommentsSheet(post: post)
        }
        .confirmationDialog("Опции за поста", isPresented: $showMoreActions, titleVisibility: .visible) {
            Button("Скрий поста") {
                withAnimation { postHidden = true }
            }
            Button("Докладвай", role: .destructive) {
                // No-op placeholder
            }
            Button("Отказ", role: .cancel) { }
        }
        .navigationDestination(isPresented: $showDogProfile) {
            if let nearby = matchingNearbyDog {
                PublicDogProfileView(dog: nearby)
            }
        }
    }
}

// MARK: - Comments Sheet

struct CommentsSheet: View {
    let post: FeedPost
    @Environment(\.dismiss) private var dismiss
    @State private var comments: [FeedComment] = []
    @State private var newCommentText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        ForEach(comments) { comment in
                            HStack(alignment: .top, spacing: 10) {
                                Circle()
                                    .fill(OPTheme.mintGradient)
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        Text(String(comment.author.prefix(1)))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(.white)
                                    }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(comment.author)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(OPTheme.text)
                                        Text(comment.timeAgo)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(OPTheme.textTertiary)
                                    }
                                    Text(comment.text)
                                        .font(.system(size: 14))
                                        .foregroundStyle(OPTheme.text)
                                }
                            }
                        }
                    }
                    .padding(OPTheme.screenPadding)
                }

                // Input
                HStack(spacing: 10) {
                    TextField("Добави коментар...", text: $newCommentText)
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(OPTheme.surfaceSunken, in: Capsule())

                    Button {
                        guard !newCommentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let comment = FeedComment(
                            id: UUID().uuidString,
                            author: "Мария",
                            text: newCommentText,
                            timeAgo: "сега"
                        )
                        comments.append(comment)
                        newCommentText = ""
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(newCommentText.isEmpty ? OPTheme.textTertiary : OPTheme.mint)
                    }
                    .disabled(newCommentText.isEmpty)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.vertical, 10)
                .background(OPTheme.surface)
                .overlay(alignment: .top) { Divider() }
            }
            .background(OPTheme.bg)
            .navigationTitle("Коментари")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.primary)
                }
            }
        }
        .onAppear {
            comments = [
                FeedComment(id: "c1", author: "Петър", text: "Колко е сладък! \u{1F60D}", timeAgo: "1 ч."),
                FeedComment(id: "c2", author: "Ана", text: "Къде е това? Искам да заведа и Мила!", timeAgo: "45 мин."),
                FeedComment(id: "c3", author: "Георги", text: "Страхотна снимка!", timeAgo: "30 мин."),
            ]
        }
    }
}
