//
//  NetworkingManager.swift
//  Bump
//
//  Created by Sweety on 10/18/25.
//

import Foundation
import CoreLocation

class NetworkingManager {
    static let shared = NetworkingManager()
    private let baseURL = "http://MacBook-Pro-290.local:8000/send_friend_request"


    // MARK: - Add Friend
    func addFriend(userId: String, friendPhone: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/add_friend") else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "friend_phone": friendPhone
        ]

        sendRequest(url: url, method: "POST", body: payload, completion: completion)
    }

    // MARK: - Get Friends
    func getFriends(userId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/get_friends?user_id=\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }.resume()
    }

    // MARK: - Update Location
    func updateLocation(userId: String, location: CLLocation, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/update_location") else { return }

        let payload: [String: Any] = [
            "user_id": userId,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]

        sendRequest(url: url, method: "POST", body: payload, completion: completion)
    }

    // MARK: - Nearby Friends
    func getNearbyFriends(userId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/nearby_friends?user_id=\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }.resume()
    }

    // MARK: - Helper Function
    private func sendRequest(url: URL, method: String, body: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("✅ Success"))
            }
        }.resume()
    }
}
