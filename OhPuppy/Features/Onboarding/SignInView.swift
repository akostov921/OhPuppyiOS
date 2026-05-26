import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppStore.self) private var store
    @State private var email = ""
    @State private var name = ""
    @State private var showEmailForm = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            OPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(OPTheme.primaryGradient)

                    Text("OhPuppy")
                        .font(.largeTitle.bold())
                        .foregroundStyle(OPTheme.text)

                    Text("Здравето на кучето ти на едно място.")
                        .font(.subheadline)
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.bottom, 48)

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
                .padding(.horizontal, OPTheme.screenPadding)

                HStack(spacing: 16) {
                    Rectangle()
                        .fill(OPTheme.border)
                        .frame(height: 1)
                    Text("или")
                        .font(.caption)
                        .foregroundStyle(OPTheme.textTertiary)
                    Rectangle()
                        .fill(OPTheme.border)
                        .frame(height: 1)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.vertical, 24)

                if showEmailForm {
                    VStack(spacing: 14) {
                        TextField("Как се казваш?", text: $name)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                            .padding(16)
                            .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny))

                        TextField("Имейл", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(16)
                            .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny))
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(OPTheme.danger)
                            .padding(.top, 8)
                    }

                    Button {
                        signInWithEmail()
                    } label: {
                        Text("Продължи")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                canSubmit ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.textTertiary.opacity(0.5)),
                                in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall)
                            )
                    }
                    .disabled(!canSubmit)
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 20)
                } else {
                    Button {
                        withAnimation(OPTheme.springAnimation) {
                            showEmailForm = true
                        }
                    } label: {
                        Text("Продължи с имейл")
                            .font(.headline)
                            .foregroundStyle(OPTheme.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(OPTheme.primarySoft, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                }

                Spacer()
            }
        }
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".")
    }

    private func signInWithEmail() {
        guard canSubmit else {
            errorMessage = "Моля, въведи валидно име и имейл."
            return
        }
        store.ownerName = name.trimmingCharacters(in: .whitespaces)
        store.ownerEmail = email.trimmingCharacters(in: .whitespaces)
        store.signIn()
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let parts = [credential.fullName?.givenName, credential.fullName?.familyName].compactMap { $0 }
                let fullName = parts.joined(separator: " ")
                if !fullName.isEmpty {
                    store.ownerName = fullName
                }
                if let appleEmail = credential.email {
                    store.ownerEmail = appleEmail
                }
                store.signIn()
            }
        case .failure:
            errorMessage = "Влизането с Apple не успя. Опитай отново."
        }
    }
}
