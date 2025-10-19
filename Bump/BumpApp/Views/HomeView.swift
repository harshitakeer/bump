//
//  HomeView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App logo or emoji
                Text("👋")
                    .font(.system(size: 60))
                
                // Title
                Text("Welcome to Bump")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Subtitle
                Text("Find your friends nearby, say hi, and make real connections again.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)

                // Location status display
                if let location = locationManager.userLocation {
                    VStack(spacing: 4) {
                        Text("📍 Your Location:")
                            .font(.headline)
                        Text("Lat: \(location.coordinate.latitude, specifier: "%.4f")")
                        Text("Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                } else {
                    Text("Fetching your location…")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                // Action button
                Button(action: {
                    locationManager.requestPermission()
                }) {
                    Text("Start Bumping")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                }

                Spacer()
            }
            .padding(.top, 80)
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
