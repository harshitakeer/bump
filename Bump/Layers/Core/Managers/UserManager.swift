import Foundation
import Combine // ✅ Required for ObservableObject and @Published

@MainActor
final class UserManager: ObservableObject {
    static let shared = UserManager()
    private init() {
        loadFromDefaults()
    }

    // MARK: - Stored properties
    @Published private(set) var currentUserId: String?
    @Published private(set) var currentUserPhone: String?

    // MARK: - Computed property
    var isLoggedIn: Bool {
        currentUserId != nil
    }

    // MARK: - Public methods
    func setCurrentUser(userId: String, phone: String? = nil) {
        currentUserId = userId
        currentUserPhone = phone
        saveToDefaults()
    }

    func getCurrentUserId() -> String? {
        return currentUserId
    }

    func logout() {
        currentUserId = nil
        currentUserPhone = nil
        clearDefaults()
    }

    // MARK: - Persistence
    private func saveToDefaults() {
        UserDefaults.standard.set(currentUserId, forKey: "currentUserId")
        UserDefaults.standard.set(currentUserPhone, forKey: "currentUserPhone")
    }

    private func loadFromDefaults() {
        currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
        currentUserPhone = UserDefaults.standard.string(forKey: "currentUserPhone")
    }

    private func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "currentUserPhone")
    }
}
