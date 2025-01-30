//
//  ProfileView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/27/25.
//

import SwiftUI

struct ProfilePicture: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.05 // 5% padding on each side
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let mediumTileWidth = usableWidth - 14 // Matches the width of the previous list

                ScrollView {
                    VStack(spacing: 16) {
                        // ✅ Profile Picture Placeholder (Sized Consistently)
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 350, height: 350) // Matches your existing profile size
                            .foregroundColor(.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .padding(.top, 20)

                        // Name & Company Text
                        Text("Carter Hammond")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Stark Industries")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.bottom, 10)
                            .multilineTextAlignment(.center)

                        // ✅ Centered List (Uniform with Previous List)
                        LazyVStack(spacing: 10) {
                            profileRow(icon: "envelope.circle", title: "Email", value: "johndoe@example.com")
                            profileRow(icon: "phone.circle", title: "Phone Number", value: "+1 (555) 123-4567")
                            profileRow(icon: "lock.circle", title: "Password", value: "Change Password")
                            profileRow(icon: "dollarsign.circle", title: "Banking Info", value: "Add/Edit your banking info")
                            profileRow(icon: "hand.raised.circle", title: "Privacy", value: "")
                            logOutRow(icon: "arrow.backward.to.line.circle", title: "Log Out")
                        }
                        .frame(width: mediumTileWidth) // ✅ Matches tile width dynamically
                        .frame(maxWidth: .infinity) // ✅ Centers it
                        .padding(.horizontal, horizontalPadding)
                    }
                    .frame(maxWidth: .infinity) // ✅ Centers VStack
                    .padding(.bottom, 48)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// 📌 Profile Row (General Settings)
private func profileRow(icon: String, title: String, value: String) -> some View {
    NavigationLink(destination: Text("\(title) Details")) {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.accentColor)
                .padding(.leading, 12)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                if !value.isEmpty {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.accentColor)
                .padding(.trailing, 10)
        }
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color(.systemGray6).opacity(0.0)) // Background color
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(.tint, lineWidth: 2) // Border
                )
        )
    }
}

// 📌 Logout Row (Red for Sign Out)
private func logOutRow(icon: String, title: String) -> some View {
    NavigationLink(destination: Text("Logging Out...")) {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.red)
                .padding(.leading, 12)
                .padding(.trailing, 5)
            Text(title)
                .font(.headline)
                .foregroundColor(.red)
            Spacer()
        }
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color(.systemGray6).opacity(0.0)) // Background color
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(Color.red, lineWidth: 2) // Border
                )
        )
    }
}

// 📌 Preview
#Preview {
    ProfilePicture()
}
