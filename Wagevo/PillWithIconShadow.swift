//
//  PillWithIconShadow.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/11/25.
//

import SwiftUI

struct PillWithIconShadow: View {
    var body: some View {
        VStack {
            PillWithIconPlusShadow(title: "BYU Football", icon: "american.football.circle.fill")
        }
    }
}

// 📌 **Pill with SF Symbol**
struct PillWithIconPlusShadow: View {
    let title: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    // Determine the stroke color based on the current color scheme
    private var strokeColor: Color {
        colorScheme == .light ? Color.black.opacity(0.30) : Color.black.opacity(0.42)
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
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
    PillWithIconPlusShadow(title: title, icon: icon)
}

#Preview {
    PillWithIconShadow()
}
