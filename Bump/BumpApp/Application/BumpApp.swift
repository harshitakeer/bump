//
//  BumpApp.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI
import UserNotifications

@main
struct BumpApp: App {
    @StateObject private var uploader = LocationUploader.shared // ✅ fixed line

    init() {
        // ✅ Initialize UserManager and set default phone if not already set
        if !UserManager.shared.isLoggedIn {
            UserManager.shared.setCurrentUser(userId: "28a76509-7bcc-439b-a7cd-4eb080da1e1f", phone: "+14258004330")
        }

        // ✅ Ask for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifications enabled")
            } else {
                print("❌ Notifications denied")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environmentObject(uploader)
                    .tabItem {
                        Label("Home", systemImage: "person.3")
                    }

                FriendRequestsView()
                    .tabItem {
                        Label("Requests", systemImage: "person.crop.circle.badge.plus")
                    }
            }
        }
    }

}








