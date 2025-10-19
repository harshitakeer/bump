//
//  ContentView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var uploader: LocationUploader
    @StateObject private var locationManager = LocationManager() // 👈 Add this

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("📍 Nearby Friends")
                    .font(.title.bold())

                if uploader.nearbyFriends.isEmpty {
                    Text("No nearby friends yet 😔")
                        .foregroundColor(.gray)
                } else {
                    List(uploader.nearbyFriends) { friend in
                        VStack(alignment: .leading) {
                            Text("User: \(friend.user_id ?? "Unknown")")
                            Text("Lat: \(friend.latitude)")
                            Text("Lon: \(friend.longitude)")
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Bump 👋")
            .onAppear {
                // 👇 Hardcode your Supabase user UUID here:
                let userId = UUID(uuidString: "062a91f2-eee6-4c2e-86fb-ec3ac3698f54")! // <- HER phone
                uploader.startUploading(locationManager: locationManager, userId: userId)
            }
        }
    }
}








