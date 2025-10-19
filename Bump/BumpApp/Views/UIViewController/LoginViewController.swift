//
//  LoginViewController.swift
//  Bump
//
//  Created by Sweety on 10/19/25.
//

// Add this to your app
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Check if user is already logged in
        if let _ = UserDefaults.standard.string(forKey: "user_id") {
            // User is already logged in, go to main app
            performSegue(withIdentifier: "toMainApp", sender: nil)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            showAlert(message: "Please enter your phone number")
            return
        }
        
        loginUser(phone: phone)
    }
    
    func loginUser(phone: String) {
        statusLabel.text = "Logging in..."
        loginButton.isEnabled = false
        
        let url = URL(string: "http://MacBook-Pro-290.local:8000/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = ["phone": phone]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        } catch {
            showAlert(message: "Error creating request")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.loginButton.isEnabled = true
                
                if let error = error {
                    self?.statusLabel.text = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.statusLabel.text = "No data received"
                    return
                }
                
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    // Store user data using UserManager
                    UserManager.shared.setCurrentUser(userId: loginResponse.user_id, phone: loginResponse.phone)
                    
                    self?.statusLabel.text = loginResponse.message
                    
                    // Navigate to main app after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.performSegue(withIdentifier: "toMainApp", sender: nil)
                    }
                    
                } catch {
                    self?.statusLabel.text = "Error parsing response"
                    print("Error: \(error)")
                }
            }
        }.resume()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Add this struct at the bottom of the file
struct LoginResponse: Codable {
    let user_id: String
    let phone: String
    let message: String
}
