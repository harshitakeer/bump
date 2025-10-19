//
//  UserManager.swift
//  Bump
//
//  Created by Sweety on 10/19/25.
//

import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    
    private init() {
        loadCurrentUser()
    }
    
    // MARK: - User Data Management
    
    func setCurrentUser(userId: String, phone: String) {
        UserDefaults.standard.set(userId, forKey: "user_id")
        UserDefaults.standard.set(phone, forKey: "phone")
        currentUser = User(id: userId, phone: phone)
    }
    
    func getCurrentUserId() -> String? {
        return UserDefaults.standard.string(forKey: "user_id")
    }
    
    func getCurrentUserPhone() -> String? {
        return UserDefaults.standard.string(forKey: "phone")
    }
    
    func isLoggedIn() -> Bool {
        return getCurrentUserId() != nil
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "phone")
        currentUser = nil
    }
    
    private func loadCurrentUser() {
        if let userId = getCurrentUserId(),
           let phone = getCurrentUserPhone() {
            currentUser = User(id: userId, phone: phone)
        }
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let phone: String
}



