//
//  TabBarView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            HomeView()
                .font(.largeTitle)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            Text("🗺️ Map")
                .font(.largeTitle)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            Text("💬 Agent")
                .font(.largeTitle)
                .tabItem {
                    Label("Agent", systemImage: "bubble.left.and.bubble.right.fill")
                }

            Text("👤 Profile")
                .font(.largeTitle)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }

            Text("⚙️ Settings")
                .font(.largeTitle)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    TabBarView()
}
