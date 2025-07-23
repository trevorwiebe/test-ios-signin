//
//  ContentView.swift
//  TestingSignIn
//
//  Created by Trevor Wiebe on 6/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isSignedIn: Bool = false
    @FocusState private var focusedField: Field?
        
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            if isSignedIn {
                SuccessView()
            }else{
                VStack(spacing: 24) {
                    // Header
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        Text("Sign in to your account")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Email", text: $email)
                                .textContentType(.username)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .email)
                                .onSubmit {
                                    focusedField = .password
                                }
                                .textFieldStyle(.roundedBorder)
                                .accessibilityLabel("Email address")
                                .accessibilityHint("Enter your email address")
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    signIn()
                                }
                                .textFieldStyle(.roundedBorder)
                                .accessibilityLabel("Password")
                                .accessibilityHint("Enter your password")
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Error Message
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 16)
                            .accessibilityLabel("Sign in error")
                            .transition(.opacity)
                    }
                    
                    // Sign In Button
                    Button(action: signIn) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Signing In..." : "Sign In")
                                .font(.body.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || !isFormValid)
                    .padding(.horizontal, 16)
                    .accessibilityLabel("Sign in button")
                    .accessibilityHint("Double tap to sign in with entered credentials")
                    
                    Spacer()
                }
                .navigationBarHidden(true)
                .background(Color(.systemGroupedBackground))
                .onTapGesture {
                    focusedField = nil
                }
            }
        }
    }

    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }
    
    // MARK: - Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
        
    private func signIn() {
        guard isFormValid else { return }
        
        isLoading = true
        showError = false
                
        // CRITICAL: Make actual network request to your domain
        guard let url = URL(string: "https://trevorwiebe.com/api/login.php") else {
            isLoading = false
            showError = true
            errorMessage = "Invalid URL"
            print("Invaid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("📤 Method: \(request.httpMethod ?? "unknown")")
        print("📤 Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Create login payload
        let loginData = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
            print("📤 Body: \(loginData)")
        } catch {
            print("❌ JSON serialization error: \(error)")
            isLoading = false
            showError = true
            errorMessage = "Failed to prepare request"
            return
        }
        
        // Make the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Log the response
            print("📥 Response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
            }
                  
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Status Code: \(httpResponse.statusCode)")
                print("📥 Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }
            
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    showError = true
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    showError = true
                    errorMessage = "Invalid response"
                    return
                }
                
                // For testing, accept any response from your domain
                // In production, you'd check for specific success status codes
                if httpResponse.statusCode == 200 {
                    // Even 404/500 from your domain can trigger password save
                    // because iOS sees the request was made to trevorwiebe.com
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            self.isSignedIn = true
                        }
                        print("✅ Navigated to success view")
                    }
                } else {
                    showError = true
                    errorMessage = "Authentication failed"
                }
            }
        }.resume()
    }
}

// Simple success view to show after sign-in
struct SuccessView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Sign In Successful!")
                .font(.title2.weight(.semibold))
            
            Text("You should see a password save prompt")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
