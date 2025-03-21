//
//  ProfileView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/27/25.
//

import SwiftUI
import PhotosUI // ✅ Required for image picker

struct SettingsViewV1: View {
    @State private var selectedImage: UIImage? // ✅ Stores uploaded image
    @State private var showImagePicker = false // ✅ Controls image picker visibility
    @Environment(\.colorScheme) var colorScheme

    // ✅ Allow default image to avoid errors
    var image: Image? = Image(systemName: "person.circle.fill")

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.05
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let mediumTileWidth = usableWidth - 14

                ZStack {
                    
                    (colorScheme == .light ? appleLightGray : Color.black)
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            // ✅ Profile Picture (Tappable for Upload)
                            VStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 350, height: 350)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                                } else {
                                    image?
                                        .resizable()
                                        .frame(width: 350, height: 350)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .onTapGesture {
                                showImagePicker = true
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(selectedImage: $selectedImage)
                            }
                            .padding(20)
                            
                            // ✅ Name & Company Text
                            Text("Carter")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(5)
                            
                            Text("Stark Industries")
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .italic()
                                .padding(.bottom, 25)
                            
                            // ✅ List of Options (Width Matches Medium Tile)
                            LazyVStack(spacing: 10) {
                                profileRow(icon: "person.circle", title: "Account")
                                profileRow(icon: "bell.circle", title: "Notifications")
                                profileRow(icon: "lock.circle", title: "Security")
                                profileRow(icon: "questionmark.circle", title: "Help")
                                logOutRow(icon: "arrow.backward.to.line.circle", title: "Log Out")
                            }
                            .frame(width: mediumTileWidth)
                            .padding(.horizontal, horizontalPadding)
                        }
                        .padding(.bottom, 48)
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// 📌 Image Picker for Uploading Profile Picture
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            picker.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// 📌 Reusable Profile Row Component (Tap & Hold Preview)
private func profileRow(icon: String, title: String) -> some View {
    ProfileRow(icon: icon, title: title)
}

private struct ProfileRow: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String

    var body: some View {
        NavigationLink(destination: ProfileView()) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.accentColor)
                    .padding(.leading, 12)
                    .padding(.trailing, 5)
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(colorScheme == .dark ? Color(darkGray) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(.tint, lineWidth: 1)
                    )
            )
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() }) // ✅ Adds haptic feedback
        .contextMenu { // ✅ Tap & Hold Preview
            NavigationLink(destination: ProfileView()) {
                Label("View \(title)", systemImage: icon)
            }
        }
    }
}

private func logOutRow(icon: String, title: String) -> some View {
    LogOutRow(icon: icon, title: title)
}

private struct LogOutRow: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
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

// 📌 Haptic Feedback Function
private func provideHapticFeedback() {
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    impactFeedbackGenerator.impactOccurred()
}

// 📌 Preview
#Preview {
    SettingsViewV1()
}
