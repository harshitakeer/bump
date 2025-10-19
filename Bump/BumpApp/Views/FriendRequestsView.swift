//
//  FriendRequestsView.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import SwiftUI

struct FriendRequestsView: View {
    @ObservedObject private var viewModel = FriendRequestsViewModel()
    @ObservedObject private var userManager = UserManager.shared

    @State private var receiverPhone = ""
    @State private var showingSuccessAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Send Friend Request Section
                HStack {
                    TextField("Enter friend's phone number", text: $receiverPhone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                        .padding(.horizontal)

                    Button {
                        Task {
                            guard let currentUserId = userManager.currentUserId else {
                                viewModel.errorMessage = "User not logged in"
                                return
                            }

                            await viewModel.sendFriendRequest(
                                senderId: currentUserId,
                                receiverPhone: receiverPhone
                            )

                            receiverPhone = ""

                            // Refresh requests after sending
                            if let currentUserPhone = userManager.currentUserPhone {
                                await viewModel.fetchRequests(for: currentUserPhone)
                            }

                            showingSuccessAlert = true
                        }
                    } label: {
                        if viewModel.isSending {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Label("Send", systemImage: "paperplane.fill")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.trailing)
                    .disabled(viewModel.isSending || receiverPhone.isEmpty)
                }

                Divider().padding(.horizontal)

                // MARK: - Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }

                // MARK: - Friend Requests List
                if viewModel.requests.isEmpty {
                    Text("No friend requests yet 👋")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.requests) { request in
                        HStack {
                            Text(request.receiver_phone)
                            Spacer()
                            Text(request.status.capitalized)
                                .foregroundColor(request.status == "pending" ? .orange : .green)
                        }
                    }
                }
            }
            .navigationTitle("👥 Friend Requests")
            .alert("✅ Friend Request Sent!", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .task {
                if let currentUserPhone = userManager.currentUserPhone {
                    await viewModel.fetchRequests(for: currentUserPhone)
                }
            }
        }
    }
}
