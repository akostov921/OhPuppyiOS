import SwiftUI

struct SignInView: View {
    @Environment(AppStore.self) private var store
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            OPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Wordmark
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

                // Sign in with Apple
                Button {
                    store.signIn()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Sign in with Apple")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(.black, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
                }
                .padding(.horizontal, OPTheme.screenPadding)

                // OR divider
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

                // Email + Password fields
                VStack(spacing: 14) {
                    TextField("Имейл", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(16)
                        .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny))

                    SecureField("Парола", text: $password)
                        .textContentType(.password)
                        .padding(16)
                        .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny))
                }
                .padding(.horizontal, OPTheme.screenPadding)

                // Sign in button
                Button {
                    store.signIn()
                } label: {
                    Text("Влез")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 20)

                Spacer()

                // Register link
                Button {
                    store.signIn()
                } label: {
                    HStack(spacing: 4) {
                        Text("Нямаш акаунт?")
                            .foregroundStyle(OPTheme.textSecondary)
                        Text("Регистрирай се")
                            .foregroundStyle(OPTheme.primary)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 32)
            }
        }
    }
}
