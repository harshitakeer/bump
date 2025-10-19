//
//  SignInView.swift
//  BumpApp
//

import SwiftUI
import AuthenticationServices   // for the Apple button

struct SignInView: View {
    // Persist a simple signed-in flag; app root can read this
    @AppStorage("auth.signedIn") private var signedIn: Bool = false

    @State private var identifier: String = ""   // phone or email
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorText: String?

    var body: some View {
        ZStack {
            // Soft vertical yellow/cream gradient like your mock
            LinearGradient(
                colors: [
                    Color(hex: "#FFF6D6"),
                    Color(hex: "#F8EAB5"),
                    Color(hex: "#FFF6D6")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {

                // MARK: Title / Wordmark
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.75))

                    // “Bump” wordmark with orange gradient + slight shadow
                    GradientText("Bump",
                                 gradient: LinearGradient(
                                    colors: [Color(hex:"#F5AA51"), Color(hex:"#D9863A")],
                                    startPoint: .top, endPoint: .bottom),
                                 size: 56, weight: .heavy)
                        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Fields card
                VStack(spacing: 14) {
                    PillField(title: "Phone or Email",
                              text: $identifier,
                              keyboard: .emailAddress)

                    PillSecureField(title: "Password",
                                    text: $password)

                    if let errorText {
                        Text(errorText)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                    }

                    // Sign In
                    Button(action: signIn) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text("Sign In").bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryCreamPill())
                    .disabled(isLoading)

                    // Create account
                    Button {
                        // In a real flow: route to SignUpView
                    } label: {
                        Text("Create an Account")
                            .font(.subheadline)
                            .underline()
                            .foregroundStyle(.black.opacity(0.7))
                    }
                    .padding(.top, 2)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                )

                // MARK: Continue with …
                VStack(spacing: 12) {
                    // Google (placeholder action)
                    Button {
                        // Hook Google Sign-In SDK here; this is a stub
                        fakeExternalSignIn(provider: "Google")
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Continue with Google").bold()
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                    }
                    .buttonStyle(OutlineCreamPill())

                    // Apple
                    SignInWithAppleButton {
                        // Handle result in coordinator; for demo, mark signed in
                        fakeExternalSignIn(provider: "Apple")
                    }
                    .frame(height: 48)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                }
                .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .padding(24)
        }
    }

    // MARK: Actions

    private func signIn() {
        errorText = nil
        guard !identifier.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Please enter your phone or email."
            return
        }
        guard password.count >= 6 else {
            errorText = "Password must be at least 6 characters."
            return
        }
        isLoading = true

        // Simulate a quick auth call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            isLoading = false
            signedIn = true        // <- route away at app root
        }
    }

    private func fakeExternalSignIn(provider: String) {
        // Replace with real SDKs later
        signedIn = true
    }
}

// MARK: - Pieces

/// Orange gradient “Bump” text
private struct GradientText: View {
    let text: String
    let gradient: LinearGradient
    let size: CGFloat
    let weight: Font.Weight

    init(_ text: String, gradient: LinearGradient, size: CGFloat, weight: Font.Weight) {
        self.text = text
        self.gradient = gradient
        self.size = size
        self.weight = weight
    }

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundStyle(gradient)
    }
}

/// Rounded cream pill text field
private struct PillField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex:"#FEF6E1"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}

/// Rounded cream pill secure field
private struct PillSecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex:"#FEF6E1"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}

/// Primary filled cream pill
private struct PrimaryCreamPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(LinearGradient(
                        colors: [Color(hex:"#FFE5B7"), Color(hex:"#FFDDA1")],
                        startPoint: .top, endPoint: .bottom))
            )
            .foregroundStyle(.black.opacity(0.8))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

/// Outline cream pill
private struct OutlineCreamPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .background(
                Capsule().fill(.white)
            )
            .overlay(
                Capsule().strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(.black.opacity(0.85))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Apple Button wrapper (keeps the native look)

private struct SignInWithAppleButton: UIViewRepresentable {
    var onRequest: () -> Void

    init(_ onRequest: @escaping () -> Void) {
        self.onRequest = onRequest
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let btn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        btn.addTarget(context.coordinator, action: #selector(Coordinator.tap), for: .touchUpInside)
        return btn
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onRequest: onRequest) }

    final class Coordinator {
        let onRequest: () -> Void
        init(onRequest: @escaping () -> Void) { self.onRequest = onRequest }
        @objc func tap() { onRequest() }
    }
}

// MARK: - Color helper

fileprivate extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0; Scanner(string: s).scanHexInt64(&v)
        self.init(.sRGB,
                  red:   Double((v & 0xFF0000) >> 16)/255,
                  green: Double((v & 0x00FF00) >> 8)/255,
                  blue:  Double( v & 0x0000FF)/255,
                  opacity: 1)
    }
}

// MARK: - Preview

#Preview { SignInView() }
