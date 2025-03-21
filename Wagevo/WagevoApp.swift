//
//  WagevoApp.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/25/25.
//

import SwiftUI
import Supabase
import AnyCodable


//Colors
let moonGray = Color(hue: 0.0, saturation: 0.0, brightness: 0.91)
let WagePurple = Color(hue: 281, saturation: 30, brightness: 10)
let defaultGray = Color(hue: 240, saturation: 0.24, brightness: 0.96)
let darkGray = Color(hue: 240, saturation: 0.03, brightness: 0.11)
let appleLightGray = Color(red: 0.9504, green: 0.9504, blue: 0.9696)

@MainActor
class AppViewModel: ObservableObject {
    @Published var session: Session?

    init() {
        Task {
            do {
                session = try await SupabaseManager.shared.supabase.auth.session
            } catch {
                print("Failed to get session: \(error.localizedDescription)")
            }
        }
    }
}

func xSmallTile(title: String, width: CGFloat) -> some View {
    return XSmallTileContent(title: title, width: width)
}

fileprivate struct XSmallTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let width: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : .white)
                .frame(width: width, height: width * 0.47)
            
            VStack {
                HStack {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding(.leading, 5)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                .padding(.top, 1)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 10)
        }
        // Use a fixed frame so that the tile is exactly the width and height provided.
        .frame(width: width, height: width * 0.47)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

func smallTile(title: String, icon: String, width: CGFloat) -> some View {
    return SmallTileContent(title: title, icon: icon, width: width)
}

fileprivate struct SmallTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .frame(width: width, height: width)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: width, maxHeight: width)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

func mediumTile(title: String, icon: String, width: CGFloat) -> some View {
    return MediumTileContent(title: title, icon: icon, width: width)
}

fileprivate struct MediumTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .frame(width: width, height: width * 0.47)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: width, maxHeight: width * 0.47)
        .compositingGroup()  // Add this to force the drawing into its own group.
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

func payTile(title: String, icon: String, width: CGFloat) -> some View {
    return PayTileContent(title: title, icon: icon, width: width)
}

fileprivate struct PayTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .frame(width: width, height: width * 0.47)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: width, maxHeight: width * 0.47)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

func largeTile(title: String, icon: String, width: CGFloat) -> some View {
    return LargeTileContent(title: title, icon: icon, width: width)
}

fileprivate struct LargeTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .frame(width: width, height: width)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: width, maxHeight: width)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

func timeClockTile(title: String, icon: String, width: CGFloat) -> some View {
    return timeClockTileContent(title: title, icon: icon, width: width)
}

fileprivate struct timeClockTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .frame(width: width, height: width * 0.45)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 10)
        }
        .frame(width: width, height: width * 0.45)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// 📌 **Pill with SF Symbol**
private struct PillWithIconView: View {
    let title: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    // Determine the stroke color based on the current color scheme
    private var strokeColor: Color {
        colorScheme == .light ? Color.black.opacity(0.23) : Color.black.opacity(0.42)
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("AccentColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(strokeColor, lineWidth: 3)
                        .blur(radius: 2)
                        .offset(x: 0, y: 0)
                        .mask(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.black, Color.gray, Color.clear]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
        )
    }
}

// Now update your existing function to use the new view:
private func pillWithIcon(title: String, icon: String) -> some View {
    PillWithIconView(title: title, icon: icon)
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: configuration.isPressed)
    }
}

@main
struct WagevoApp: App {
    //Onboarding/Welcome screen stuff
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var appViewModel = AppViewModel()


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

