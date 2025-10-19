////
////  ProfileView.swift
////  BumpApp
////
//
//import SwiftUI
//import EventKit
//
//// MARK: - Models
//
//struct UserProfile: Codable, Equatable {
//    var name: String = "Bob Wilson"
//    var handle: String = "@bobwilson"
//    var school: String = "Stanford University"
//    var bio: String = "Computer Science student passionate about AI and meeting new people. Always down for coffee or a hike!"
//}
//
//struct ScheduleItem: Identifiable {
//    let id = UUID()
//    let time: String
//    let title: String
//    let place: String
//    let busy: Bool
//}
//
//// MARK: - Palette
//
//fileprivate extension Color {
//    static let bumpBlue1   = Color(hex: "#89C7E7")
//    static let bumpBlue2   = Color(hex: "#ADD8E5")
//    static let bumpBlue3   = Color(hex: "#C4EBF1")
//    static let bumpYellow1 = Color(hex: "#FFFFC2")
//    static let bumpYellow3 = Color(hex: "#FFD301")
//
//    init(hex: String) {
//        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if s.hasPrefix("#") { s.removeFirst() }
//        var rgb: UInt64 = 0; Scanner(string: s).scanHexInt64(&rgb)
//        self.init(.sRGB,
//                  red:   Double((rgb & 0xFF0000) >> 16)/255,
//                  green: Double((rgb & 0x00FF00) >> 8)/255,
//                  blue:  Double( rgb & 0x0000FF)/255,
//                  opacity: 1)
//    }
//}
//
//// MARK: - Calendar service
//
//final class CalendarService {
//    private let store = EKEventStore()
//
//    enum AccessState { case undetermined, granted, denied }
//
//    func accessState() -> AccessState {
//        let status = EKEventStore.authorizationStatus(for: .event)
//        if #available(iOS 17, *) {
//            switch status {
//            case .notDetermined: return .undetermined
//            case .authorized, .fullAccess: return .granted
//            case .writeOnly, .restricted, .denied: return .denied
//            @unknown default: return .denied
//            }
//        } else {
//            switch status {
//            case .notDetermined: return .undetermined
//            case .authorized:    return .granted
//            default:             return .denied
//            }
//        }
//    }
//
//    func requestAccess(completion: @escaping (Bool)->Void) {
//        if #available(iOS 17, *) {
//            store.requestFullAccessToEvents { ok, _ in completion(ok) }
//        } else {
//            store.requestAccess(to: .event) { ok, _ in completion(ok) }
//        }
//    }
//
//    /// All user calendars (optionally filtered to Google).
//    func calendars(googleOnly: Bool) -> [EKCalendar] {
//        let all = store.calendars(for: .event)
//        guard googleOnly else { return all }
//        // Google usually appears as CalDAV with source title like "Gmail" or the Google email.
//        return all.filter { cal in
//            (cal.source.sourceType == .calDAV) &&
//            (cal.source.title.lowercased().contains("gmail") || cal.source.title.lowercased().contains("google"))
//        }
//    }
//
//    /// Fetch today’s events from selected calendars. If `calendars` is empty, it’ll still work (EventKit will treat as none).
//    func fetchTodayEvents(calendars: [EKCalendar]?) -> [EKEvent] {
//        let cal = Calendar.current
//        let start = cal.startOfDay(for: Date())
//        let end = cal.date(byAdding: .day, value: 1, to: start)!
//
//        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
//        return store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
//    }
//}
//
//// MARK: - Lightweight persistence
//
//private enum ProfileStore {
//    private static let key = "bump.profile"
//    static func load() -> UserProfile? {
//        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
//        return try? JSONDecoder().decode(UserProfile.self, from: data)
//    }
//    static func save(_ profile: UserProfile) {
//        if let data = try? JSONEncoder().encode(profile) {
//            UserDefaults.standard.set(data, forKey: key)
//        }
//    }
//}
//
//// MARK: - Profile View
//
//struct ProfileView: View {
//    @EnvironmentObject private var router: AppRouter   // <- add this
//
//    @State private var me = ProfileStore.load() ?? UserProfile()
//    @State private var showEdit = false
//
//    // Schedule data (replaced when importing)
//    @State private var today: [ScheduleItem] = [
//        .init(time: "9:00 AM",  title: "CS 229 Lecture", place: "Gates Hall",  busy: true),
//        .init(time: "11:00 AM", title: "Free Time",      place: "Campus",      busy: false),
//        .init(time: "1:00 PM",  title: "Lunch Meeting",  place: "Coupa Cafe",  busy: true),
//        .init(time: "3:00 PM",  title: "Free Time",      place: "Library",     busy: false),
//        .init(time: "5:00 PM",  title: "Gym",            place: "AOERC",       busy: false)
//    ]
//
//    private let calService = CalendarService()
//
//    // import settings
//    enum ImportScope: String, CaseIterable, Identifiable { case all = "All", google = "Google only"; var id: String { rawValue } }
//    @State private var scope: ImportScope = .google
//    @State private var showCalendarHelp = false
//    @State private var lastImportHadNoGoogle = false
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//
//                // Header
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack(spacing: 12) {
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .symbolRenderingMode(.palette)
//                            .foregroundStyle(Color.white, Color.bumpBlue1)
//                            .frame(width: 56, height: 56)
//                            .shadow(radius: 2)
//
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text(me.name).font(.title3).bold()
//                            Text(me.handle).foregroundStyle(.blue)
//                            HStack(spacing: 6) {
//                                Image(systemName: "graduationcap").font(.caption)
//                                Text(me.school).font(.subheadline)
//                            }
//                            .foregroundStyle(.secondary)
//                        }
//
//                        Spacer()
//
//                        Button { showEdit = true } label: {
//                            Label("Edit", systemImage: "square.and.pencil")
//                        }
//                        .sheet(isPresented: $showEdit) {
//                            NavigationStack {
//                                EditProfileView(profile: $me) { updated in
//                                    ProfileStore.save(updated)
//                                }
//                            }
//                        }
//                    }
//
//                    Text(me.bio)
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                }
//                .cardStyle()
//
//                // Today’s Schedule (+ Import from Calendar)
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Text("Today’s Schedule").font(.headline)
//                        Spacer()
//                        Picker("", selection: $scope) {
//                            Text("All").tag(ImportScope.all)
//                            Text("Google").tag(ImportScope.google)
//                        }
//                        .pickerStyle(.segmented)
//                        .frame(maxWidth: 220)
//                    }
//
//                    HStack {
//                        Button { importTodayFromCalendar() } label: {
//                            Label("Import from Calendar", systemImage: "calendar.badge.plus")
//                        }
//                        .font(.subheadline)
//
//                        if lastImportHadNoGoogle && scope == .google {
//                            Button {
//                                showCalendarHelp = true
//                            } label: {
//                                Label("How to connect Google", systemImage: "questionmark.circle")
//                            }
//                            .font(.footnote)
//                        }
//                    }
//
//                    ForEach(today) { item in
//                        HStack {
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text(item.time).font(.caption)
//                                Text(item.title).bold()
//                                HStack(spacing: 6) {
//                                    Image(systemName: "mappin.and.ellipse").font(.caption2)
//                                    Text(item.place.isEmpty ? "—" : item.place).font(.caption)
//                                }
//                                .foregroundStyle(.secondary)
//                            }
//                            Spacer()
//                            Text(item.busy ? "Busy" : "Free")
//                                .font(.caption).bold()
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 10)
//                                .background(
//                                    Capsule().fill(item.busy ? Color.bumpYellow1 : Color.green.opacity(0.2))
//                                )
//                        }
//                        .padding(10)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(Color.white)
//                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.06)))
//                        )
//                    }
//                }
//                .cardStyle()
//                .alert("Connect Google Calendar", isPresented: $showCalendarHelp) {
//                    Button("Open Settings") {
//                        if let url = URL(string: UIApplication.openSettingsURLString) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
//                    Button("OK", role: .cancel) {}
//                } message: {
//                    Text("""
//To import Google Calendar, add your Google account to the iOS Calendar app:
//Settings → Calendar → Accounts → Add Account → Google.
//Then make sure your calendars are enabled in the Calendar app. Come back and tap Import again.
//""")
//                }
//
//                // Settings shortcut — switches to Settings tab
//                Button {
//                    router.selected = .settings
//                } label: {
//                    HStack(spacing: 12) {
//                        Image(systemName: "gearshape.fill").font(.headline)
//                        Text("Settings").font(.headline)
//                        Spacer()
//                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color.white)
//                            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
//                    )
//                }
//                // Settings shortcut — switches to Settings tab
//                Button {
//                    router.selected = .settings                 // <— switches tab
//                } label: {
//                    HStack(spacing: 12) {
//                        Image(systemName: "gearshape.fill").font(.headline)
//                        Text("Settings").font(.headline)
//                        Spacer()
//                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color.white)
//                            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
//                    )
//                }
//
//               
//                .cardStyle()
//                .padding(.bottom, 24)
//            }
//            .padding()
//        }
//        .background(
//            LinearGradient(colors: [Color.bumpBlue3.opacity(0.25), Color.bumpYellow1.opacity(0.2)],
//                           startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()
//        )
//        .navigationTitle("Profile")
//        .onAppear {
//            // Ask once on first open; user can also tap Import manually.
//            switch calService.accessState() {
//            case .undetermined:
//                calService.requestAccess { ok in if ok { importTodayFromCalendar() } }
//            case .granted:
//                importTodayFromCalendar()
//            case .denied:
//                break
//            }
//        }
//    }
//
//    // MARK: - Calendar import
//
//    private func importTodayFromCalendar() {
//        guard calService.accessState() == .granted else { return }
//
//        let googleOnly = (scope == .google)
//        let cals = calService.calendars(googleOnly: googleOnly)
//        lastImportHadNoGoogle = googleOnly && cals.isEmpty
//
//        let events = calService.fetchTodayEvents(calendars: googleOnly ? cals : nil)
//
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//
//        // Map EKEvent → ScheduleItem, include all-day events (show “All day”)
//        let mapped: [ScheduleItem] = events.map { e in
//            let timeString: String = e.isAllDay ? "All day" : formatter.string(from: e.startDate)
//            let isBusy = (e.availability == .free) ? false : true
//            return ScheduleItem(
//                time: timeString,
//                title: e.title.isEmpty ? "(No title)" : e.title,
//                place: e.location ?? "",
//                busy: isBusy
//            )
//        }
//
//        if !mapped.isEmpty {
//            today = mapped
//        } else if googleOnly {
//            lastImportHadNoGoogle = true
//        }
//    }
//}
//
//// MARK: - Edit Profile Page
//
//struct EditProfileView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Binding var profile: UserProfile
//    var onSave: (UserProfile) -> Void = { _ in }
//
//    @State private var draft: UserProfile
//    @State private var bioCount: Int = 0
//    private let bioLimit = 200
//
//    init(profile: Binding<UserProfile>, onSave: @escaping (UserProfile) -> Void = { _ in }) {
//        self._profile = profile
//        self._draft = State(initialValue: profile.wrappedValue)
//        self.onSave = onSave
//    }
//
//    var body: some View {
//        Form {
//            Section("Name") {
//                TextField("Your name", text: $draft.name)
//                    .textContentType(.name)
//            }
//
//            Section("Handle") {
//                TextField("@handle", text: $draft.handle)
//                    .textInputAutocapitalization(.never)
//                    .autocorrectionDisabled()
//                    .onChange(of: draft.handle) { _, v in
//                        if !v.hasPrefix("@") {
//                            draft.handle = "@" + v.replacingOccurrences(of: "@", with: "")
//                        }
//                    }
//                Text("This is how friends can find you.")
//                    .font(.caption).foregroundStyle(.secondary)
//            }
//
//            Section("School") {
//                TextField("School / Organization", text: $draft.school)
//                    .textContentType(.organizationName)
//            }
//
//            Section("Bio") {
//                ZStack(alignment: .bottomTrailing) {
//                    TextEditor(text: $draft.bio)
//                        .frame(minHeight: 120)
//                        .onChange(of: draft.bio) { _, newVal in
//                            if newVal.count > bioLimit {
//                                draft.bio = String(newVal.prefix(bioLimit))
//                            }
//                            bioCount = draft.bio.count
//                        }
//                    Text("\(bioCount)/\(bioLimit)")
//                        .font(.caption2)
//                        .padding(8)
//                        .foregroundStyle(.secondary)
//                }
//            }
//        }
//        .navigationTitle("Edit Profile")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Cancel") { dismiss() }
//            }
//            ToolbarItem(placement: .confirmationAction) {
//                Button("Save") {
//                    profile = draft
//                    ProfileStore.save(draft)
//                    dismiss()
//                }.bold()
//            }
//        }
//        .onAppear { bioCount = draft.bio.count }
//    }
//}
//
//// MARK: - Small helpers
//
//fileprivate struct StatTile: View {
//    let number: Int
//    let label: String
//    var body: some View {
//        VStack {
//            Text("\(number)").font(.title2).bold()
//            Text(label).font(.caption).foregroundStyle(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.bumpBlue2.opacity(0.45))
//        )
//    }
//}
//
//fileprivate extension View {
//    func cardStyle() -> some View {
//        self
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.white)
//                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
//            )
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    NavigationStack { ProfileView() }
//}
