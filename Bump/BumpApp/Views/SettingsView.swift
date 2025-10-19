//
//  SettingsView.swift
//  BumpApp
//

import SwiftUI
import Combine
import EventKit
import CoreLocation
import UserNotifications

// MARK: - Services

final class CalendarAccess: ObservableObject {
    private let store = EKEventStore()
    @Published var granted: Bool = false

    init() { refresh() }

    func refresh() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17, *) {
            // iOS 17+: only .fullAccess means we can read events
            granted = (status == .fullAccess)
        } else {
            // iOS 16 and earlier
            granted = (status == .authorized)
        }
    }


    func request() {
        if #available(iOS 17, *) {
            store.requestFullAccessToEvents { [weak self] ok, _ in
                DispatchQueue.main.async { self?.granted = ok }
            }
        } else {
            store.requestAccess(to: .event) { [weak self] ok, _ in
                DispatchQueue.main.async { self?.granted = ok }
            }
        }
    }
}

final class LocationAccess: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var status: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        status = manager.authorizationStatus
    }

    func requestWhenInUse() { manager.requestWhenInUseAuthorization() }

    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
    }

    var isAuthorized: Bool {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }
}

// MARK: - View

struct SettingsView: View {
    // Persisted settings
    @AppStorage("settings.location.alwaysAllow") private var alwaysAllowLocation: Bool = false
    @AppStorage("settings.location.maxMiles")    private var maxMiles: Double = 0.5

    @AppStorage("settings.calendar.enabled")     private var calendarAccessOn: Bool = false
    @AppStorage("settings.calendar.autoDecline") private var autoDeclineBusy: Bool = true
    @AppStorage("settings.calendar.shareFree")   private var shareFreeBusy: Bool = true

    @AppStorage("settings.notif.friendBumps")    private var notifFriendBumps: Bool = true
    @AppStorage("settings.notif.newConnections") private var notifNewConnections: Bool = true
    @AppStorage("settings.notif.dnd")            private var doNotDisturb: Bool = false

    @AppStorage("settings.privacy.showOnline")   private var showOnlineStatus: Bool = true

    @StateObject private var cal = CalendarAccess()
    @StateObject private var loc = LocationAccess()

    @State private var showDeleteConfirm = false
    @State private var showPrivacyPolicy = false
    @State private var showConnectedApps = false
    @State private var notifPermissionHint = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PrivacyNoteCard()

                locationCard
                calendarCard
                notificationsCard
                privacyCard
                dangerZone
            }
            .padding()
        }
        .navigationTitle("Settings")
        .background(
            LinearGradient(colors: [Color(.systemGroupedBackground),
                                    Color(.secondarySystemGroupedBackground)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .onAppear { cal.refresh() }
    }

    // MARK: - Cards

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            header(icon: "location.circle.fill", tint: .blue,
                   title: "Location", subtitle: "Control how Bump uses your location")

            Toggle(isOn: $alwaysAllowLocation) {
                VStack(alignment: .leading) {
                    Text("Always Allow Location")
                    Text("Required for detecting nearby friends")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .onChange(of: alwaysAllowLocation) { _, on in
                if on && !loc.isAuthorized { loc.requestWhenInUse() }
            }
            .tint(.blue)

            VStack(alignment: .leading) {
                HStack {
                    Text("Maximum Distance")
                    Spacer()
                    Text(String(format: "%.1f mi", maxMiles))
                        .font(.caption).foregroundStyle(.secondary)
                }
                Slider(value: $maxMiles, in: 0.1...0.5, step: 0.5)
            }

            if !loc.isAuthorized {
                InlineHint(
                    icon: "exclamationmark.triangle.fill",
                    text: "Location permission is off. Enable it in Settings to use Nearby.",
                    actionTitle: "Open Settings",
                    action: loc.openSystemSettings
                )
            }
        }
        .cardStyle()
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            header(icon: "calendar.circle.fill", tint: .pink,
                   title: "Calendar", subtitle: "Smart scheduling features")

            Toggle(isOn: Binding(
                get: { calendarAccessOn && cal.granted },
                set: { on in
                    calendarAccessOn = on
                    if on && !cal.granted { cal.request() }
                })
            ) {
                VStack(alignment: .leading) {
                    Text("Calendar Access")
                    Text("Let AI check your availability automatically")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .tint(.pink)

            Toggle("Auto-Decline When Busy", isOn: $autoDeclineBusy)
                .tint(.pink)
                .disabled(!(calendarAccessOn && cal.granted))

            Toggle("Share Schedule", isOn: $shareFreeBusy)
                .tint(.pink)
                .disabled(!(calendarAccessOn && cal.granted))

            if calendarAccessOn && !cal.granted {
                Text("Tip: To import Google Calendar, add your Google account to iOS Calendar (Settings → Calendar → Accounts) and enable your calendars.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }

    private var notificationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            header(icon: "bell.circle.fill", tint: .orange,
                   title: "Notifications", subtitle: "Control who can bump you")

            Toggle("Friend Bumps", isOn: $notifFriendBumps)
                .tint(.orange)
                .onChange(of: notifFriendBumps) { _, on in if on { requestNotifIfNeeded() } }

            Toggle("New Connections", isOn: $notifNewConnections)
                .tint(.orange)
                .onChange(of: notifNewConnections) { _, on in if on { requestNotifIfNeeded() } }

            Toggle("Do Not Disturb", isOn: $doNotDisturb)
                .tint(.orange)

            if notifPermissionHint {
                InlineHint(
                    icon: "exclamationmark.circle",
                    text: "Enable notifications in iOS Settings to get bumps.",
                    actionTitle: "Open Settings",
                    action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
        }
        .cardStyle()
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            header(icon: "lock.circle.fill", tint: .green,
                   title: "Privacy", subtitle: "Control your visibility")

            Toggle("Show Online Status", isOn: $showOnlineStatus)
                .tint(.green)

            Divider().padding(.vertical, 4)

            navRow(title: "View Privacy Policy", systemImage: "doc.text.magnifyingglass") {
                showPrivacyPolicy = true
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                NavigationStack {
                    ScrollView {
                        Text("""
We use coarse location and free/busy information to suggest meetups. We never share exact GPS or event details without your consent. You can disable location, calendar, or notifications anytime in Settings.
""")
                        .padding()
                    }
                    .navigationTitle("Privacy Policy")
                    .toolbar { ToolbarItem(placement: .primaryAction) { Button("Done") { showPrivacyPolicy = false } } }
                }
            }

            navRow(title: "Connected Apps", systemImage: "link") {
                showConnectedApps = true
            }
            .sheet(isPresented: $showConnectedApps) {
                NavigationStack {
                    List {
                        Label("Apple Calendar (EventKit)", systemImage: "calendar")
                        Label("Google Calendar (via iOS Calendar)", systemImage: "g.circle")
                    }
                    .navigationTitle("Connected Apps")
                    .toolbar { ToolbarItem(placement: .primaryAction) { Button("Done") { showConnectedApps = false } } }
                }
            }
        }
        .cardStyle()
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                HStack {
                    Label("Delete Account", systemImage: "trash")
                    Spacer()
                }
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { /* TODO: hook up */ }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes your data from this device. Server-side deletion will be added later.")
            }
        }
        .cardStyle()
    }

    // MARK: - Helpers

    private func header(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.title2)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func navRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .buttonStyle(.plain)
    }

    private func requestNotifIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            } else if settings.authorizationStatus != .authorized {
                DispatchQueue.main.async { notifPermissionHint = true }
            }
        }
    }
}

// MARK: - Small UI bits

private struct InlineHint: View {
    let icon: String
    let text: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
            Text(text).font(.caption).foregroundStyle(.secondary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action).font(.caption)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.12)))
    }
}

private struct PrivacyNoteCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.checkerboard").font(.title3)
            Text("Your location and calendar data are only used to help you connect. We never share your data without permission.")
                .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
    }
}

fileprivate extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            )
    }
}
