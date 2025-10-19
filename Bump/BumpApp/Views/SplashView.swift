//
//  SplashView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI

struct SplashView: View {
    @State private var airplaneOffset: CGSize = CGSize(width: -200, height: -150)
    @State private var airplaneRotation: Double = -30
    @State private var showB = false
    @State private var showAirplane = true
    @State private var goToHome = false
    
    var body: some View {
        if goToHome {
            TabBarView()
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.yellow.opacity(0.25),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ZStack {
                    // MARK: - The "b" letter
                    Text("b")
                        .font(.system(size: 160, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.9))
                        .scaleEffect(showB ? 1 : 0.6)
                        .opacity(showB ? 1 : 0.2)
                        .animation(.easeInOut(duration: 1.0), value: showB)
                        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)

                    // MARK: - Paper Airplane
                    if showAirplane {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.black)
                            .offset(airplaneOffset)
                            .rotationEffect(.degrees(airplaneRotation))
                            .shadow(color: .blue.opacity(0.3), radius: 6, x: 3, y: 3)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 2.0)) {
                                    airplaneOffset = CGSize(width: 20, height: 10)
                                    airplaneRotation = 20
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation(.easeOut(duration: 0.8)) {
                                        showAirplane = false
                                        showB = true
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        goToHome = true
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}


