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
    @FocusState private var focusedField: Field?
        
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationView {
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
        
        // Simulate authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulate authentication logic here
            // On success, dismiss this view to trigger password save prompt
            // On failure, show error message
            
            let success = Bool.random() // Simulate random success/failure for demo
            
            if success {
                // Authentication successful
                // Dismissing the view or navigating away triggers iOS to show
                // "Save Password?" prompt automatically
                isLoading = false
                // Navigate to main app or dismiss this view
            } else {
                // Authentication failed
                isLoading = false
                showError = true
                errorMessage = "Invalid email or password. Please try again."
            }
        }
    }
}

#Preview {
    ContentView()
}
