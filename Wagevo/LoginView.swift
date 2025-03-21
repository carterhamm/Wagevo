//
//  LoginView.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/3/25.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @Binding var showLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isLoggedIn = false
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    enum Field { case email, password }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer().frame(height: geo.size.height * 0.20)
                    
                    // Page Title
                    HStack {
                        Text("Login")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, geo.size.width * 0.08)
                    .padding(.bottom, 20)
                    
                    Spacer().frame(height: geo.size.height * 0.1)
                    
                    // Input fields
                    VStack(spacing: geo.size.height * 0.03) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .foregroundColor(.white)
                                .font(.headline)
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .email)
                                .modifier(PurpleLineFieldStyleLogin(isFocused: focusedField == .email))
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .foregroundColor(.white)
                                .font(.headline)
                            SecureField("Enter your password", text: $password)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .password)
                                .modifier(PurpleLineFieldStyleLogin(isFocused: focusedField == .password))
                        }
                    }
                    .padding(.horizontal, geo.size.width * 0.08)
                    
                    Spacer().frame(height: geo.size.height * 0.05)
                    
                    // Login Button
                    Button(action: { attemptLogin() }) {
                        Text("Login")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 350, height: 75)
                            .background(Color.accentColor)
                            .cornerRadius(40)
                    }
                    // Button is always enabled because isLoginValid always returns true
                    .disabled(!isLoginValid())
                    
                    Spacer()
                }
                
                // Error Banner
                if showError {
                    VStack {
                        Text(errorMessage)
                            .font(.callout)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(width: 350)
                            .background(Capsule().fill(Color.red))
                            .transition(.opacity)
                        Spacer()
                    }
                    .padding(.top, geo.size.height * 0.02)
                    .animation(.easeInOut(duration: 0.3), value: showError)
                }
                
                // Logged-in Welcome
                if isLoggedIn {
                    LoggedInWelcomeViewFullScreen {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            showLogin = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .overlay(
                Button(action: {
                    showLogin = false
                    provideSuccessHaptic()
                }) {
                    Text("Exit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(Color.accentColor)
                        .cornerRadius(30)
                }
                .padding(.top, geo.size.height * 0.02)
                .padding(.trailing, geo.size.width * 0.06),
                alignment: .topTrailing
            )
        }
    }
    
    // MARK: - Helpers
    
    // Now always returns true so that any email/password combination works.
    private func isLoginValid() -> Bool {
        return true
    }
    
    private func attemptLogin() {
        dismissKeyboard()
        // Call the real Supabase login via AuthManager
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                isLoggedIn = true
            case .failure(let error):
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showError = false }
        }
    }
    
    private func provideSuccessHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - PurpleLineFieldStyleLogin
struct PurpleLineFieldStyleLogin: ViewModifier {
    var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .overlay(
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 2)
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: isFocused ? geometry.size.width : 0, height: 2)
                                .animation(.easeInOut(duration: 0.3), value: isFocused)
                        }
                    }
                }
            )
    }
}

// MARK: - LoggedInWelcomeViewFullScreen
struct LoggedInWelcomeViewFullScreen: View {
    var onCompletion: () -> Void
    @State private var show = false
    @State private var scale: CGFloat = 1
    @State private var textOpacity: Double = 1.0

    var body: some View {
        ZStack {
            // Always opaque background to completely cover LoginView
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                ZStack {
                    // Masked layer using the hand wave icon for the animated effect
                    Color.clear
                        .mask(
                            Image(systemName: "hand.wave.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .scaleEffect(scale)
                        )
                    // Foreground hand wave icon that scales, fades, and wiggles
                    Image(systemName: "hand.wave.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.accentColor)
                        .opacity(show ? 0 : 1)
                        .scaleEffect(scale)
                        .symbolEffect(.wiggle)
                }
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .opacity(textOpacity)
                Spacer()
            }
        }
        .onAppear {
            // Initial shrink effect (like the sample)
            withAnimation(.spring(duration: 1).delay(0.5)) {
                scale = 0.8
            }
            // Then expand the hand and fade out icon and text
            withAnimation(.spring(duration: 1).delay(1.0)) {
                show = true
                scale = 35
                textOpacity = 0
            }
            // Transition as soon as the animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onCompletion()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showLogin: .constant(true))
    }
}
