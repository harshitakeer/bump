//
//  LocationUploader.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import Foundation
import Supabase
import CoreLocation
import Combine

struct SupaFriend: Codable, Identifiable {
    let id: Int?
    let user_id: String?
    let latitude: Double
    let longitude: Double
    let created_at: String?
}

// MARK: - Simple AnyEncodable wrapper
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

    @MainActor
    class LocationUploader: ObservableObject {
        static let shared = LocationUploader()
        @Published var nearbyFriends: [SupaFriend] = []
        
        // ✅ Add these two stored properties
        private var timer: Timer?
        private var lastNotifiedFriends: Set<String> = []  // prevent repeat notifications
        private var myUserId: UUID!

        
        private let client = SupabaseClient(
            supabaseURL: URL(string: "https://mhejrqwnnxsxcmowfner.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZWpycXdubnhzeGNtb3dmbmVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MDU0NzgsImV4cCI6MjA3NjM4MTQ3OH0.FIwR5fNavJGToWO712YDc9i6hbBU8jn6Eo3rzcLIHuc"
        )
        
        // MARK: Start automatic uploading every 10 seconds
        func startUploading(locationManager: LocationManager, userId: UUID) {
            self.myUserId = userId
            timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                guard let loc = locationManager.userLocation else {
                    print("⚠️ Waiting for location...")
                    return
                }
                
                Task {
                    do {
                        let data: [[String: AnyEncodable]] = [[
                            "user_id": AnyEncodable(userId.uuidString),
                            "latitude": AnyEncodable(loc.coordinate.latitude),
                            "longitude": AnyEncodable(loc.coordinate.longitude)
                        ]]

                        try await self.client
                            .from("user_locations")
                            .upsert(data)
                            .execute()

                        print("✅ Uploaded: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                        await self.fetchNearbyFriends(myLocation: loc)  // ✅ stays with await

                    } catch {
                        print("❌ Upload failed: \(error)")
                    }
                }

            }
        }
        
        // MARK: Fetch nearby friends (within 50 meters)
        func fetchNearbyFriends(myLocation: CLLocation, radiusMeters: Double = 100) async {
            do {
                let response = try await client
                    .from("user_locations")
                    .select("*")
                    .execute()

                let friends = try JSONDecoder().decode([SupaFriend].self, from: response.data)

                // Filter nearby friends within the radius and not yourself
                let nearby = friends.filter { friend in
                    guard let uid = friend.user_id,
                          uid != myUserId.uuidString else { return false }

                    let friendLoc = CLLocation(latitude: friend.latitude, longitude: friend.longitude)
                    return myLocation.distance(from: friendLoc) <= radiusMeters
                }

                // If there’s at least one new nearby friend → send a local notification
                if !nearby.isEmpty {
                    for friend in nearby {
                        if let fid = friend.user_id {
                            NotificationManager.shared.sendProximityAlert(friendId: fid)
                        }
                    }
                }

                await MainActor.run {
                    self.nearbyFriends = nearby
                }

                print("📡 \(friends.count) total, \(nearby.count) nearby friends")
            } catch {
                print("❌ Error fetching friends: \(error)")
            }
        }

        
        func stopUploading() {
            timer?.invalidate()
            timer = nil
        }
    }







