//
//  FriendRequestsViewModel.swift
//  Bump
//
//  Updated for full Supabase integration
//

import Foundation
import Combine


class FriendRequestsViewModel: ObservableObject {
    @Published var requests: [FriendRequest] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    
    // MARK: - Send Friend Request
    func sendFriendRequest(senderId: String, receiverPhone: String) async {
        DispatchQueue.main.async {
            self.isSending = true
            self.errorMessage = nil
        }
        
        guard let url = URL(string: "\(SupabaseConfig.baseURL)/send_friend_request") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isSending = false
            }
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "sender_id": senderId,
            "receiver_phone": receiverPhone
        ]

        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let httpResponse = response as? HTTPURLResponse
            print("📦 Status:", httpResponse?.statusCode ?? 0)
            print("📦 Response:", String(data: data, encoding: .utf8) ?? "")

            if httpResponse?.statusCode == 200 {
                DispatchQueue.main.async {
                    self.errorMessage = nil
                    self.isSending = false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error \(httpResponse?.statusCode ?? 0)"
                    self.isSending = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
                self.isSending = false
            }
        }
    }

    // MARK: - Fetch Pending Requests
    func fetchRequests(for phone: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let url = URL(string: "\(SupabaseConfig.baseURL)/get_pending_requests") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["phone": phone]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoded = try JSONDecoder().decode(FriendRequestResponse.self, from: data)
            DispatchQueue.main.async {
                self.requests = decoded.data
                self.isLoading = false
            }
        } catch {
            print("❌ Fetch failed:", error)
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch requests: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }



    // MARK: - Respond to Friend Request
    func respond(to request: FriendRequest, status: String) async {
        guard let url = URL(string: "\(SupabaseConfig.baseURL)/respond_to_request") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "id": request.id,
            "status": status
        ]

        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let httpResponse = response as? HTTPURLResponse
            print("📦 Response:", String(data: data, encoding: .utf8) ?? "")
            if httpResponse?.statusCode == 200 {
                await fetchRequests(for: request.receiver_phone)
            }
        } catch {
            print("❌ Respond failed:", error)
        }
    }
}

// MARK: - Data Models
struct FriendRequestResponse: Codable {
    let success: Bool
    let data: [FriendRequest]
}

struct FriendRequest: Identifiable, Codable {
    // Use the backend `id` as the SwiftUI identifier
    let id: Int
    
    let sender_id: String
    let receiver_phone: String
    let status: String
    let created_at: String
}




