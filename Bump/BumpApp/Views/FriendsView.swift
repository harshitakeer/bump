////
////  FriendsView.swift
////  BumpApp
////
//
//import SwiftUI
//import UserNotifications
//
//// MARK: - Palette
//
//fileprivate extension Color {
//    static let creamBG   = Color(hex: "#FFF7E9")
//    static let cardCream = Color(hex: "#FFF0DA")
//    static let chipCream = Color(hex: "#FCE2BE")
//    static let orange1   = Color(hex: "#F5B66F")
//    static let orange2   = Color(hex: "#E9895A")
//    static let orangeInk = Color(hex: "#C06A36")
//
//    init(hex: String) {
//        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if s.hasPrefix("#") { s.removeFirst() }
//        var v: UInt64 = 0; Scanner(string: s).scanHexInt64(&v)
//        self.init(.sRGB,
//                  red:   Double((v & 0xFF0000) >> 16)/255,
//                  green: Double((v & 0x00FF00) >> 8)/255,
//                  blue:  Double( v & 0x0000FF)/255,
//                  opacity: 1)
//    }
//}
//
//// MARK: - Fonts (custom if available)
//
//fileprivate func bumpScriptFont(_ size: CGFloat) -> Font {
//    // If you add a font named "BumpScript" to the project, we'll use it; else fallback.
//    if UIFont(name: "BumpScript", size: size) != nil {
//        return .custom("BumpScript", size: size)
//    }
//    return .system(size: size, weight: .regular, design: .rounded)
//}
//
//fileprivate func bumpBodyFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
//    if UIFont(name: "BumpSans", size: size) != nil {
//        return .custom("BumpSans", size: size)
//    }
//    return .system(size: size, weight: weight, design: .rounded)
//}
//
//// MARK: - Models
//
//struct Friend: Identifiable, Equatable {
//    enum Status: Equatable {
//        case freeNow
//        case freeIn(minutes: Int)
//        case doNotDisturb
//
//        var label: String {
//            switch self {
//            case .freeNow:               return "Free now"
//            case .freeIn(let m):         return "Free in \(m) min"
//            case .doNotDisturb:          return "Do not disturb"
//            }
//        }
//        var icon: String {
//            switch self {
//            case .freeNow, .freeIn:      return "calendar.badge.clock"
//            case .doNotDisturb:          return "moon.fill"
//            }
//        }
//        var color: Color {
//            switch self {
//            case .freeNow:               return .green
//            case .freeIn:                return .blue
//            case .doNotDisturb:          return .orange
//            }
//        }
//    }
//
//    let id = UUID()
//    var name: String
//    var distanceMiles: Double
//    var status: Status
//    var avatar: String = "person.circle.fill"
//}
//
//struct IncomingRequest: Identifiable, Equatable {
//    let id = UUID()
//    var name: String
//    var phone: String
//}
//
//struct SentRequest: Identifiable, Equatable {
//    let id = UUID()
//    var phone: String
//    var when: Date = .init()
//}
//
//// MARK: - View
//
//struct FriendsView: View {
//    // Fake roster
//    @State private var friends: [Friend] = [
//        Friend(name: "Ava Kim", distanceMiles: 0.5, status: .freeNow),
//        Friend(name: "Diego Cruz", distanceMiles: 0.3, status: .freeIn(minutes: 10)),
//        Friend(name: "Priya Shah", distanceMiles: 0.8, status: .doNotDisturb)
//    ]
//
//    // Requests
//    @State private var incoming: [IncomingRequest] = [
//        .init(name: "Maya Patel",  phone: "(415) 555-0123"),
//        .init(name: "Liam Nguyen",  phone: "(206) 555-0444")
//    ]
//    @State private var sent: [SentRequest] = []
//
//    // Sheets
//    @State private var showSendSheet = false
//    @State private var showAcceptSheet = false
//
//    // Toast
//    @State private var showToast = false
//    @State private var toastText = ""
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 18) {
//
//                    // Friend Requests section (header + two buttons)
//                    VStack(spacing: 14) {
//                        Text("Friend Requests")
//                            .font(bumpScriptFont(26))
//                            .foregroundStyle(Color.orangeInk)
//
//                        HStack(spacing: 14) {
//                            GradientPillButton(title: "Send", systemImage: "paperplane.fill") {
//                                showSendSheet = true
//                            }
//                            GradientPillButton(title: "Accept", systemImage: "hand.thumbsup.fill") {
//                                showAcceptSheet = true
//                            }
//                            .opacity(incoming.isEmpty ? 0.6 : 1)
//                            .disabled(incoming.isEmpty)
//                        }
//
//                        HStack(spacing: 12) {
//                            if !incoming.isEmpty {
//                                Chip(text: "\(incoming.count) pending")
//                            }
//                            if !sent.isEmpty {
//                                Chip(text: "\(sent.count) sent")
//                            }
//                        }
//                    }
//                    .friendsCardStyle()
//
//                    // Friend Cards
//                    ForEach(friends) { f in
//                        FriendCard(friend: f,
//                                   onBump: { bump(friend: f) },
//                                   onMore: { /* add menu actions later */ })
//                    }
//                }
//                .padding()
//            }
//            .background(Color.creamBG.ignoresSafeArea())
//            .navigationTitle("Friends")
//            .toolbarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showSendSheet) { SendSheet() }
//            .sheet(isPresented: $showAcceptSheet) { AcceptSheet() }
//            .overlay(alignment: .bottom) { toastView }
//            .onAppear { configureLocalNotifications() }
//        }
//    }
//
//    // MARK: - Sheets
//
//    @ViewBuilder
//    private func SendSheet() -> some View {
//        SendRequestSheet { name, rawPhone in
//            let phone = formatPhone(rawPhone)
//            sent.insert(.init(phone: phone), at: 0)
//            toast("Request sent to \(name.isEmpty ? phone : name)")
//        }
//    }
//
//    @ViewBuilder
//    private func AcceptSheet() -> some View {
//        NavigationStack {
//            List {
//                ForEach(incoming) { item in
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text(item.name)
//                            .font(bumpBodyFont(16, weight: .semibold))
//                        HStack(spacing: 6) {
//                            Image(systemName: "phone.fill")
//                            Text(item.phone)
//                        }
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//
//                        HStack(spacing: 10) {
//                            Button {
//                                // Accept = move to friends
//                                withAnimation {
//                                    incoming.removeAll { $0.id == item.id }
//                                    friends.insert(
//                                        Friend(name: item.name,
//                                               distanceMiles: Double.random(in: 0.2...1.0),
//                                               status: .freeIn(minutes: Int.random(in: 5...30))),
//                                        at: 0
//                                    )
//                                }
//                                toast("You’re now friends with \(item.name)!")
//                            } label: {
//                                Label("Accept", systemImage: "checkmark.circle.fill")
//                                    .frame(maxWidth: .infinity)
//                            }
//                            .buttonStyle(OrangeFilledButton())
//
//                            Button(role: .destructive) {
//                                withAnimation { incoming.removeAll { $0.id == item.id } }
//                                toast("Declined \(item.name)")
//                            } label: {
//                                Label("Decline", systemImage: "xmark.circle.fill")
//                                    .frame(maxWidth: .infinity)
//                            }
//                            .buttonStyle(OutlinedDestructiveButton())
//                        }
//                        .padding(.top, 2)
//                    }
//                    .listRowBackground(Color.cardCream)
//                    .padding(.vertical, 6)
//                }
//            }
//            .scrollContentBackground(.hidden)
//            .background(Color.creamBG)
//            .navigationTitle("Incoming")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) { Button("Done") { showAcceptSheet = false } }
//            }
//        }
//        .presentationDetents([.medium, .large])
//    }
//
//    // MARK: - Actions
//
//    private func bump(friend: Friend) {
//        let lines = [
//            "👋 \(friend.name), want to grab coffee?",
//            "⚡️ Free soon? Let’s meet up!",
//            "📍 I’m nearby—down to bump?",
//            "🗓️ Free in a bit—link up?",
//            "🥐 Coffee run? I’m around.",
//            "✨ Let’s catch up IRL!"
//        ]
//        notify(title: "Bump sent to \(friend.name)", body: lines.randomElement() ?? "Let’s meet up!")
//        toast("Bump sent to \(friend.name)")
//    }
//
//    private func toast(_ text: String) {
//        toastText = text
//        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { showToast = true }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            withAnimation(.easeOut) { showToast = false }
//        }
//    }
//
//    // MARK: - Local notifications
//
//    private func configureLocalNotifications() {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
//    }
//
//    private func notify(title: String, body: String) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body  = body
//        content.sound = .default
//        content.interruptionLevel = .active
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.25, repeats: false)
//        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
//    }
//
//    // MARK: - Helpers
//
//    private func formatPhone(_ raw: String) -> String {
//        let digits = raw.filter(\.isNumber)
//        var s = ""
//        for (i, ch) in digits.enumerated() {
//            if i == 0 { s.append("(") }
//            if i == 3 { s.append(") ") }
//            if i == 6 { s.append("-") }
//            s.append(ch)
//        }
//        return s
//    }
//
//    @ViewBuilder
//    private var toastView: some View {
//        if showToast {
//            Text(toastText)
//                .font(bumpBodyFont(13, weight: .semibold))
//                .padding(.horizontal, 14).padding(.vertical, 10)
//                .background(Capsule().fill(Color.black.opacity(0.85)))
//                .foregroundStyle(.white)
//                .padding(.bottom, 22)
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//        }
//    }
//}
//
//// MARK: - Subviews
//
//private struct FriendCard: View {
//    let friend: Friend
//    var onBump: () -> Void
//    var onMore: () -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(spacing: 12) {
//                Image(systemName: friend.avatar)
//                    .resizable()
//                    .symbolRenderingMode(.palette)
//                    .foregroundStyle(.white, .gray.opacity(0.55))
//                    .frame(width: 52, height: 52)
//                    .clipShape(Circle())
//                    .shadow(radius: 1)
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Name")
//                        .font(bumpScriptFont(18))
//                        .foregroundStyle(Color.orangeInk.opacity(0.9))
//                    Text(friend.name)
//                        .font(bumpBodyFont(16, weight: .semibold))
//                        .foregroundStyle(.brown)
//
//                    HStack(spacing: 10) {
//                        Chip(icon: friend.status.icon, text: friend.status.label, tint: friend.status.color)
//                        HStack(spacing: 6) {
//                            Image(systemName: "location")
//                            Text("\(String(format: "%.1f", friend.distanceMiles)) miles away")
//                        }
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                    }
//                }
//
//                Spacer()
//
//                Menu {
//                    Button("More…", action: onMore)
//                } label: {
//                    Image(systemName: "ellipsis.circle")
//                        .font(.title3)
//                        .foregroundStyle(.secondary)
//                }
//            }
//
//            Button(action: onBump) {
//                Text("Bump")
//                    .font(bumpBodyFont(17, weight: .bold))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 10)
//                    .background(
//                        RoundedRectangle(cornerRadius: 14)
//                            .fill(LinearGradient(colors: [.orange1, .orange2],
//                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
//                            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
//                    )
//                    .foregroundStyle(.white)
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 18)
//                .fill(Color.cardCream)
//                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
//        )
//    }
//}
//
//// Friend request “Send” sheet
//private struct SendRequestSheet: View {
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var name: String = ""
//    @State private var phone: String = ""
//
//    var onSend: (String, String) -> Void
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section {
//                    TextField("Name (optional)", text: $name)
//                        .font(bumpBodyFont(16))
//                    TextField("Phone Number", text: $phone)
//                        .keyboardType(.phonePad)
//                        .font(bumpBodyFont(16))
//                } header: {
//                    Text("Send Friend Request")
//                        .font(bumpScriptFont(20))
//                        .foregroundStyle(Color.orangeInk)
//                }
//            }
//            .navigationTitle("Send")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Send") {
//                        guard !phone.filter(\.isNumber).isEmpty else { return }
//                        onSend(name, phone)
//                        dismiss()
//                    }.bold()
//                }
//            }
//        }
//        .presentationDetents([.medium])
//    }
//}
//
//// MARK: - Small UI bits
//
//private struct Chip: View {
//    var icon: String? = nil
//    var text: String
//    var tint: Color = .orangeInk
//
//    var body: some View {
//        HStack(spacing: 6) {
//            if let icon { Image(systemName: icon) }
//            Text(text)
//        }
//        .font(.caption)
//        .padding(.horizontal, 10)
//        .padding(.vertical, 6)
//        .background(Capsule().fill(Color.chipCream))
//        .foregroundStyle(tint)
//    }
//}
//
//private struct GradientPillButton: View {
//    let title: String
//    let systemImage: String
//    var action: () -> Void
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 8) {
//                Image(systemName: systemImage)
//                Text(title)
//            }
//            .font(bumpBodyFont(17, weight: .semibold))
//            .padding(.horizontal, 18)
//            .padding(.vertical, 10)
//            .background(
//                RoundedRectangle(cornerRadius: 14)
//                    .fill(LinearGradient(colors: [.orange1, .orange2],
//                                         startPoint: .topLeading, endPoint: .bottomTrailing))
//                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
//            )
//            .foregroundStyle(.white)
//        }
//    }
//}
//
//private struct OrangeFilledButton: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(bumpBodyFont(15, weight: .semibold))
//            .padding(.vertical, 8)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(LinearGradient(colors: [.orange1, .orange2],
//                                         startPoint: .topLeading, endPoint: .bottomTrailing))
//            )
//            .foregroundStyle(.white)
//            .opacity(configuration.isPressed ? 0.85 : 1)
//    }
//}
//
//private struct OutlinedDestructiveButton: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(bumpBodyFont(15, weight: .regular))
//            .padding(.vertical, 8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.red.opacity(0.6), lineWidth: 1)
//            )
//            .foregroundStyle(.red)
//            .opacity(configuration.isPressed ? 0.7 : 1)
//    }
//}
//
//fileprivate extension View {
//    func friendsCardStyle() -> some View {
//        self
//            .padding(16)
//            .background(
//                RoundedRectangle(cornerRadius: 18)
//                    .fill(Color.cardCream)
//                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
//            )
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    NavigationStack { FriendsView() }
//}
