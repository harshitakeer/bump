//
//  ContentView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var uploader: LocationUploader

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("📍 Nearby Friends")
                    .font(.title.bold())

                if uploader.nearbyFriends.isEmpty {
                    Text("No nearby friends yet 😌")
                        .foregroundColor(.gray)
                } else {
                    List(uploader.nearbyFriends) { friend in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("👤 \(friend.user_id ?? "Unknown")")
                                .font(.headline)
                            Text("📏 Approx. \(Int(friend.distance ?? 0)) meters away")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Bump 👋")
        }
    }
}










