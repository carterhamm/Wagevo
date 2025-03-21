//
//  SettingsView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/27/25.
//

import SwiftUI
import PhotosUI // ✅ Required for image picker

struct SettingsView: View {
    @State private var selectedImage: UIImage?  // ✅ Stores uploaded image
    @State private var showImagePicker = false    // ✅ Controls image picker visibility
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var userInfo = UserInfo.shared
    
    // ✅ Allow default image to avoid errors
    var image: Image? = Image(systemName: "person.circle.fill").symbolRenderingMode(.hierarchical)
    
    // Namespace for matched transitions (iOS 18 Navigation Transition)
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // Layout measurements
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let smallTileWidth = (usableWidth - 14) / 2
                let mediumTileWidth = usableWidth
                
                ZStack {
                    (colorScheme == .light ? appleLightGray : Color.black)
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            // MARK: Account Tile (mediumTile)
                            NavigationLink {
                                // Destination with zoom transition
                                ProfileView()
                                    .navigationTransition(.zoom(sourceID: "accountTile", in: namespace))
                            } label: {
                                // Profile Picture Tile (as label) with matched transition source
                                ZStack {
                                    accountTile(title: "", icon: "", width: mediumTileWidth)
                                    
                                    HStack {
                                        VStack {
                                            if let selectedImage = selectedImage {
                                                Image(uiImage: selectedImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 120, height: 120)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 10)
                                                    .overlay(
                                                        Circle().stroke(Color.accentColor, lineWidth: 3)
                                                    )
                                            } else {
                                                image?
                                                    .resizable()
                                                    .frame(width: 120, height: 120)
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                        .onTapGesture {
                                            showImagePicker = true
                                        }
                                        .sheet(isPresented: $showImagePicker) {
                                            ImagePicker(selectedImage: $selectedImage)
                                        }
                                        .padding(.leading, 20)
                                        
                                        // Name & Company Text
                                        VStack(alignment: .leading) {
                                            Text(userInfo.firstName)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .padding(.top, 8)
                                                .padding(.bottom, 5)
                                            Text("Stark Industries")
                                                .font(.title3)
                                                .fontWeight(.light)
                                                .foregroundColor(.accentColor)
                                                .padding(.top, 5)
                                                .padding(.bottom, 8)
                                        }
                                        .padding([.top, .bottom, .trailing])
                                        .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                }
                                .matchedTransitionSource(id: "accountTile", in: namespace)
                            }
                            
                            // MARK: Notifications Tile
                            NavigationLink {
                                NotificationsView()
                                    .navigationTransition(.zoom(sourceID: "notificationsTile", in: namespace))
                            } label: {
                                ZStack {
                                    mediumTile(title: "Notifications", icon: "bell.circle.fill", width: mediumTileWidth)
                                        .matchedTransitionSource(id: "notificationsTile", in: namespace)
                                    VStack {
                                        HStack {
                                            Text("Push")
                                                .fontWeight(.semibold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                            Spacer()
                                            Image(systemName: "app.badge")
                                                .font(.headline)
                                                .fontWeight(.regular)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(Color.accentColor, colorScheme == .dark ? .white : .black)
                                        }
                                        .padding(.top, 35)
                                        .padding(.bottom, 5)
                                        HStack {
                                            Text("SMS")
                                                .fontWeight(.semibold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                            Spacer()
                                            Image(systemName:"message.badge")
                                                .font(.headline)
                                                .fontWeight(.regular)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(Color.accentColor, colorScheme == .dark ? .white : .black)
                                        }
                                        .padding(.top, 6)
                                        .padding(.bottom, 6)
                                        HStack {
                                            Text("Email")
                                                .fontWeight(.semibold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                            Spacer()
                                            Image(systemName: "envelope.badge")
                                                .font(.headline)
                                                .fontWeight(.regular)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(Color.accentColor, colorScheme == .dark ? .white : .black)
                                        }
                                        .padding(.top, 6)
                                        .padding(.bottom, 6)
                                    }
                                    .padding()
                                    .padding(.horizontal, 4)
                                    .padding(.top, 10)
                                }
                            }
                                
                            
                            // MARK: Security Tile
                            HStack {
                                NavigationLink {
                                    SecurityView()
                                        .navigationTransition(.zoom(sourceID: "securityTile", in: namespace))
                                } label: {
                                    ZStack {
                                        smallTile(title: "Security", icon: "lock.circasdfle.fill", width: smallTileWidth)
                                            .matchedTransitionSource(id: "securityTile", in: namespace)
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "lock")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .fontWeight(.bold)
                                                    .frame(width: smallTileWidth * 0.35)
                                            }
                                            .padding(27)
                                        }
                                    }
                                }
                                
                                // MARK: Help Tile
                                NavigationLink {
                                    HelpView()
                                        .navigationTransition(.zoom(sourceID: "helpTile", in: namespace))
                                } label: {
                                    ZStack {
                                        smallTile(title: "Help", icon: "questionmark.cirasdfcle.fill", width: smallTileWidth)
                                            .matchedTransitionSource(id: "helpTile", in: namespace)
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "questionmark")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .fontWeight(.bold)
                                                    .frame(width: smallTileWidth * 0.3)
                                            }
                                            .padding(27)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 48)
                    }
                    .navigationTitle("Settings")
                }
            }
        }
    }
}

func accountTile(title: String, icon: String, width: CGFloat) -> some View {
    return accountTileContent(title: title, icon: icon, width: width)
}

fileprivate struct accountTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .frame(width: width, height: width * 0.40)
            VStack {
                HStack {
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
        .compositingGroup()  // Forces drawing into its own group.
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Dummy Views with Filler Content

struct NotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var emailNotifications = true
    @State private var pushNotifications = false
    @State private var smsNotifications = true
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? appleLightGray : Color.black)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Toggle("Email Notifications", isOn: $emailNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle("Push Notifications", isOn: $pushNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle("SMS Notifications", isOn: $smsNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SecurityView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var twoFactorEnabled = false
    @State private var biometricEnabled = true
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? appleLightGray : Color.black)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Toggle("Two-Factor Authentication", isOn: $twoFactorEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle("Biometric Authentication", isOn: $biometricEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Button(action: {
                    // Dummy action for changing password
                }) {
                    Text("Change Password")
                        .font(.headline)
                        .padding()
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            (colorScheme == .light ? appleLightGray : Color.black)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Frequently Asked Questions")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    Group {
                        Text("Q: How do I reset my password?")
                            .font(.headline)
                        Text("A: You can reset your password by going to the Security settings.")
                            .font(.subheadline)
                    }
                    Group {
                        Text("Q: How do I update my profile?")
                            .font(.headline)
                        Text("A: Tap on your profile picture to update your information.")
                            .font(.subheadline)
                    }
                    Group {
                        Text("Q: How do I contact support?")
                            .font(.headline)
                        Text("A: You can contact support via the Help section or email us at support@example.com.")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Log Out Row (unchanged)

private struct LogOutRow: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            hasCompletedOnboarding = false // ✅ Resets onboarding so it shows on next launch
        }) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .padding(.leading, 12)
                    .padding(.trailing, 5)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(colorScheme == .dark ? Color(darkGray) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(Color.red, lineWidth: 2)
                    )
            )
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() }) // ✅ Adds haptic feedback
    }
}

// MARK: - Haptic Feedback

private func provideHapticFeedback() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

// MARK: - Preview

#Preview {
    SettingsView()
}
