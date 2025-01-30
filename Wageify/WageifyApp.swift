//
//  WageifyApp.swift
//  Wageify
//
//  Created by Carter Hammond on 1/25/25.
//



import SwiftUI

//Colors
let moonGray = Color(hue: 0.0, saturation: 0.0, brightness: 0.91)
let WagePurple = Color(hue: 281, saturation: 30, brightness: 10)
let defaultGray = Color(hue: 240, saturation: 0.24, brightness: 0.96)


func xSmallTile(title: String, width: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: width * 0.47) // ✅ Scales dynamically
        VStack {
            HStack {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AccentColor"))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
    .frame(maxWidth: width, maxHeight: width * 0.47)
    .clipped()
}

func smallTile(title: String, icon: String, width: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: width)
        
        VStack {
            HStack {
                pillWithIcon(title: title, icon: icon) // ✅ Adds pill
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
    .frame(maxWidth: width, maxHeight: width)
    .clipped()
}

func mediumTile(title: String, icon: String, width: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: width * 0.47)
        
        VStack {
            HStack {
                pillWithIcon(title: title, icon: icon) // ✅ Adds pill
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
    .frame(maxWidth: width, maxHeight: width * 0.47)
    .clipped()
}

func bankTile(title: String, icon: String, width: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: width * 0.45)
        
        VStack {
            HStack {
                pillWithIcon(title: title, icon: icon) // ✅ Adds pill
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
    .frame(maxWidth: width, maxHeight: width * 0.45)
    .clipped()
}

func payTile(title: String, icon: String, width: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: width * 0.47)
        
        VStack {
            HStack {
                pillWithIcon(title: title, icon: icon) // ✅ Adds pill
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
    .frame(maxWidth: width, maxHeight: width * 0.47)
    .clipped()
}

func largeTile(title: String, icon: String, width: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: width)
        
        VStack {
            HStack {
                pillWithIcon(title: title, icon: icon) // ✅ Adds pill
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
    .frame(maxWidth: width, maxHeight: width)
    .clipped()
}

// 📌 **Pill with SF Symbol**
private func pillWithIcon(title: String, icon: String) -> some View {
    HStack(spacing: 5) {
        Image(systemName: icon)
            .foregroundColor(.white)
        Text(title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .background(
        RoundedRectangle(cornerRadius: 15)
            .fill(Color("AccentColor"))
    )
}

@main
struct WageifyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                Tabs() // ✅ Main app content after onboarding
            } else {
                OnboardingView() // ✅ Shows onboarding only once
            }
        }
    }
}
