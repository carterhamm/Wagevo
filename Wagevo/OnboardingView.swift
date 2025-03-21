//
//  OnboardingView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/30/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showLogin = false
    @State private var showSignUp = false
    // Updated totalPages from 6 to 5 (removed "You're All Set!" page)
    private let totalPages = 5

    var body: some View {
        ZStack {
            PurpleCirclesView() // Background animation

            VStack {
                Spacer()

                // Main Content with PageView
                TabView(selection: $currentPage) {
                    WelcomePage().tag(0)
                    OnboardingPage(title: "Track Your Earnings",
                                   subtitle: "See your shifts and payments instantly.",
                                   icon: "chart.bar.fill").tag(1)
                    OnboardingPage(title: "Get Paid Instantly",
                                   subtitle: "No more waiting for payday.",
                                   icon: "dollarsign.circle.fill").tag(2)
                    OnboardingPage(title: "Manage Your Card",
                                   subtitle: "Control spending with ease.",
                                   icon: "creditcard.fill").tag(3)
                    // Removed the "You're All Set!" page.
                    SignUpOrLoginView(showLogin: $showLogin, showSignUp: $showSignUp)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Removes default page dots
                // Disable swipe on pages except the last one.
                .overlay(
                    Group {
                        if currentPage != totalPages - 1 {
                            Color.clear.gesture(DragGesture().onEnded { value in
                                if value.translation.width < -50 && currentPage < totalPages - 1 {
                                    withAnimation {
                                        currentPage += 1
                                        rigidHaptic()
                                    }
                                }
                                if value.translation.width > 50 && currentPage > 0 {
                                    withAnimation {
                                        currentPage -= 1
                                        rigidHaptic()
                                    }
                                }
                            })
                        }
                    }
                )

                Spacer()

                // Custom Page Indicator Dots (hidden on the SignUp/Login page)
                if currentPage < totalPages - 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.accentColor : (index < currentPage ? Color.accentColor : Color.white.opacity(0.5)))
                                .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                        }
                    }
                    .padding(.bottom, 15)
                }

                // Next Button on all pages except the last
                if currentPage < totalPages - 1 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                            rigidHaptic()
                        }
                    }) {
                        pillButton(title: "Next", color: Color.accentColor)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width < -50 && currentPage < totalPages - 1 {
                    withAnimation {
                        currentPage += 1
                        rigidHaptic()
                    }
                }
                if value.translation.width > 50 && currentPage > 0 {
                    withAnimation {
                        currentPage -= 1
                        rigidHaptic()
                    }
                }
            }
        )
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(showLogin: $showLogin)
        }
        .fullScreenCover(isPresented: $showSignUp) {
            RegisterView(showSignUp: $showSignUp)
        }
    }
}

// MARK: - Haptic Feedback

func rigidHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .rigid)
    generator.impactOccurred()
}

// MARK: - Reusable Components & Pages

struct WelcomePage: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                    .frame(height: geo.size.height * 0.42)
                
                VStack(spacing: 10) {
                    Text("Welcome to Wagevo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Life doesn’t happen biweekly.")
                        .font(.title3)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.vertical, 10)
                
                Spacer()
            }
            .frame(width: geo.size.width) // Prevents shifting issues.
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                    .frame(height: geo.size.height * 0.31) // Adjusted for better centering
                
                VStack(spacing: 20) {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geo.size.height * 0.12)
                        .foregroundColor(.white)
                        .symbolEffect(.wiggle.up.byLayer, options: .nonRepeating)
                    
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: geo.size.width * 0.9)
                    
                    Text(subtitle)
                        .font(.title3)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: geo.size.width * 0.9)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: geo.size.width * 0.9)
                
                Spacer()
            }
            .frame(width: geo.size.width) // Prevents shifting issues.
        }
    }
}

struct SignUpOrLoginView: View {
    @Binding var showLogin: Bool
    @Binding var showSignUp: Bool

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 10) {
                Text("Get Started")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Log in or sign up to start using Wagevo.")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.vertical, 10)
            
            Spacer()
            
            // More fluid integration of the buttons:
            VStack(spacing: 20) {
                Button(action: {
                    showLogin = true
                    rigidHaptic()
                }) {
                    pillOutlinedButton(title: "Log In", borderColor: Color.accentColor)
                }
                
                Button(action: {
                    showSignUp = true
                    rigidHaptic()
                }) {
                    pillButton(title: "Sign Up", color: Color.accentColor)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

func pillButton(title: String, color: Color) -> some View {
    Text(title)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .frame(width: 350, height: 75)
        .background(color)
        .cornerRadius(40)
}

func pillOutlinedButton(title: String, borderColor: Color) -> some View {
    Text(title)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(borderColor)
        .frame(width: 350, height: 75)
        .background(Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 40).stroke(borderColor, lineWidth: 3))
}

struct PurpleCirclesView: View {
    private let circleCount = 4
    @State private var offsets: [CGSize] = Array(repeating: CGSize(width: 0, height: -35), count: 4)
    @State private var sizes: [CGFloat] = (0..<4).map { _ in CGFloat.random(in: 300...500) }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .fill(Color("AccentColor").opacity(0.3))
                    .frame(width: sizes[index], height: sizes[index])
                    .offset(offsets[index])
                    .onAppear {
                        animateCircle(index)
                    }
            }
        }
    }
    
    private func animateCircle(_ index: Int) {
        let duration = Double.random(in: 15...25)
        let xRange: CGFloat = CGFloat.random(in: 600...1100)
        let yRange: CGFloat = CGFloat.random(in: 600...1100)
        
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            if index == 0 {
                let randomY = CGFloat.random(in: -yRange...yRange) - 50
                let clampedY = min(max(randomY, -200), 200)
                offsets[index] = CGSize(
                    width: CGFloat.random(in: -xRange...xRange),
                    height: clampedY
                )
            } else {
                offsets[index] = CGSize(
                    width: CGFloat.random(in: -xRange...xRange),
                    height: CGFloat.random(in: -yRange...yRange) - 50
                )
            }
        }
    }
}

func pillTextField(_ placeholder: String, text: Binding<String>) -> some View {
    TextField(placeholder, text: text)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.accentColor, lineWidth: 2))
        .padding(.horizontal, 20)
}

func pillSecureField(_ placeholder: String, text: Binding<String>) -> some View {
    SecureField(placeholder, text: text)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.accentColor, lineWidth: 2))
        .padding(.horizontal, 20)
}


#Preview {
    OnboardingView()
}
