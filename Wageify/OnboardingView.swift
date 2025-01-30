//
//  OnboardingView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/30/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    private let totalPages = 5 // ✅ Includes Welcome Page

    var body: some View {
        ZStack {
            FloatingCirclesView() // ✅ Background animation

            VStack {
                // ✅ Page Indicator Dots
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.white.opacity(0.5))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    }
                }
                .padding(.top, 40)

                Spacer()

                // ✅ Dynamic Page Content
                switch currentPage {
                case 0:
                    WelcomePage()
                case 1:
                    OnboardingPage(title: "Track Your Earnings", subtitle: "See your shifts and payments instantly.")
                case 2:
                    OnboardingPage(title: "Get Paid Instantly", subtitle: "No more waiting for payday.")
                case 3:
                    OnboardingPage(title: "Manage Your Card", subtitle: "Control spending with ease.")
                case 4:
                    OnboardingPage(title: "You're All Set!", subtitle: "Start using Wageify now and get paid instantly.")
                default:
                    EmptyView()
                }

                Spacer()

                // ✅ Next or Finish Button
                Button(action: {
                    if currentPage < totalPages - 1 {
                        provideNextHaptic()
                        currentPage += 1
                    } else {
                        provideFinishHaptic()
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text(currentPage == totalPages - 1 ? "Finish" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.accentColor)
                        .cornerRadius(25)
                }
                .padding(.bottom, 40)
            }
            .padding()

            // ✅ Invisible Tappable Areas for Navigation
            HStack {
                // ◀️ Left Tap - Go Back
                Color.clear
                    .contentShape(Rectangle()) // ✅ Expands tappable area
                    .onTapGesture {
                        if currentPage > 0 {
                            provideBackHaptic()
                            currentPage -= 1
                        }
                    }

                // ▶️ Right Tap - Go Forward
                Color.clear
                    .contentShape(Rectangle()) // ✅ Expands tappable area
                    .onTapGesture {
                        if currentPage < totalPages - 1 {
                            provideNextHaptic()
                            currentPage += 1
                        } else {
                            provideFinishHaptic()
                            hasCompletedOnboarding = true
                        }
                    }
            }
        }
        .ignoresSafeArea() // ✅ Ensures full-screen tap detection
    }

    // ✅ Short Haptic Feedback for Each "Next" Press
    private func provideNextHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .rigid)
        impact.impactOccurred()
    }

    // ✅ Gentle Haptic for Going Back
    private func provideBackHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .soft)
        impact.impactOccurred()
    }

    // ✅ Strong, Satisfying Haptic on "Finish"
    private func provideFinishHaptic() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
}

// 📌 **Welcome Page Component**
struct WelcomePage: View {
    var body: some View {
        VStack {
            Text("Welcome to Wageify")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()

            Text("Get Paid Instantly. No More Waiting.")
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// 📌 **Reused Onboarding Page Component**
struct OnboardingPage: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()

            Text(subtitle)
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    OnboardingView()
}
