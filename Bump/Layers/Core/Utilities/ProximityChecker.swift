//
//  ProximityChecker.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import CoreLocation
import Supabase

struct Friend: Codable {
    let user_id: String?
    let latitude: Double
    let longitude: Double
}


class ProximityChecker {
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://mhejrqwnnxsxcmowfner.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZWpycXdubnhzeGNtb3dmbmVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MDU0NzgsImV4cCI6MjA3NjM4MTQ3OH0.FIwR5fNavJGToWO712YDc9i6hbBU8jn6Eo3rzcLIHuc"
    )

    func fetchNearbyFriends(myLocation: CLLocation, radiusMeters: Double = 200) async -> [Friend] {
        do {
            let response: [Friend] = try await client
                .from("user_locations")
                .select()
                .execute()
                .value  // <-- this extracts the decoded data
            
            return response.filter { friend in
                let friendLoc = CLLocation(latitude: friend.latitude, longitude: friend.longitude)
                let distance = myLocation.distance(from: friendLoc)
                return distance <= radiusMeters
            }
        } catch {
            print("❌ Error fetching friends: \(error)")
            return []
        }
    }
}

