//
//  SignUpView.swift
//  BumpApp
//

import SwiftUI

struct SignUpView: View {
    // You can read this at app root to decide what to show
    @AppStorage("auth.signedIn") private var signedIn: Bool = false

    // Form state
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var username  = ""
    @State private var password  = ""
    @State private var phone     = ""
    @State private var email     = ""

    @State private var isLoading = false
    @State private var errorText: String?

    @Environment(\.dismiss) private var dismiss    // for “Back to Sign In”

    var body: some View {
        ZStack {
            // Soft yellow/cream gradient like your design
            LinearGradient(
                colors: [Color(hex:"#FFF6D6"), Color(hex:"#F8EAB5"), Color(hex:"#FFF6D6")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    // Title
                    Text("Create an account")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Card with fields
                    VStack(spacing: 14) {
                        PillField(title: "First Name", text: $firstName, keyboard: .namePhonePad)
                        PillField(title: "Last Name",  text: $lastName,  keyboard: .namePhonePad)
                        PillField(title: "Username",   text: $username,  keyboard: .default)
                        PillSecureField(title: "Create a Password", text: $password)

                        PillField(title: "Phone Number", text: $phone, keyboard: .phonePad)

                        // OR separator
                        HStack {
                            Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
                            Text("OR")
                                .font(.caption)
                                .foregroundStyle(.black.opacity(0.5))
                            Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
                        }
                        .padding(.horizontal, 6)

                        PillField(title: "Email Address", text: $email, keyboard: .emailAddress)

                        if let errorText {
                            Text(errorText)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 2)
                        }

                        // Create Account
                        Button(action: createAccount) {
                            HStack(spacing: 8) {
                                if isLoading { ProgressView().tint(.black) }
                                Text("Create Account").bold()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryCreamPill())
                        .disabled(isLoading)
                        .padding(.top, 6)

                        // Back to Sign In
                        Button {
                            dismiss()  // if pushed/presented from SignIn
                        } label: {
                            Text("Back to Sign In")
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

                    Spacer(minLength: 0)
                }
                .padding(24)
            }
        }
    }

    // MARK: - Actions

    private func createAccount() {
        errorText = nil

        // Basic validations to match the mock’s intent
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Please enter your first name."; return
        }
        guard !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Please enter your last name."; return
        }
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Please choose a username."; return
        }
        guard password.count >= 6 else {
            errorText = "Password must be at least 6 characters."; return
        }
        // Require either phone OR email
        if phone.trimmingCharacters(in: .whitespaces).isEmpty &&
            email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorText = "Enter a phone number or an email address."; return
        }

        isLoading = true

        // Simulate a sign-up call; store basics you might want later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false

            // Persist a few defaults for later screens if you like
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "bump.profile.name")
            UserDefaults.standard.set("@\(username)", forKey: "bump.profile.handle")
            // Mark the user signed in
            signedIn = true
        }
    }
}

// MARK: - Reusable UI helpers (pill fields + styles)

// Rounded cream pill text field
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
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex:"#FEF6E1")))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
    }
}

// Rounded cream pill secure field
private struct PillSecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex:"#FEF6E1")))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
    }
}

// Cream filled primary pill button
private struct PrimaryCreamPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .background(
                Capsule().fill(
                    LinearGradient(colors: [Color(hex:"#FFE5B7"), Color(hex:"#FFDDA1")],
                                   startPoint: .top, endPoint: .bottom)
                )
            )
            .foregroundStyle(.black.opacity(0.85))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

// Color helper
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
#Preview { SignUpView() }
