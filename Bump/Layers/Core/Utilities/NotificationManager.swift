//
//  NotificationManager.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func sendProximityAlert(friendId: String) {
        let content = UNMutableNotificationContent()
        content.title = "👋 Bump Alert"
        content.body = "Your friend (\(friendId.prefix(6))) is nearby!"
        content.sound = UNNotificationSound.default

        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error)")
            } else {
                print("📣 Notification sent for \(friendId)")
            }
        }
    }
}


