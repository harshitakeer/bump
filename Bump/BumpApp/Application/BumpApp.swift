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
            ContentView()
                .environmentObject(uploader) // ✅ passes uploader to ContentView
        }
    }
}







