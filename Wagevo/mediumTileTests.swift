//
//  mediumTileTests.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/15/25.
//

import SwiftUI

struct mediumTileTests: View {
    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)
            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth
            VStack {
                Spacer()
                ZStack {
                    HStack {
                        Spacer()
                        medTile(title: "Hello", icon: "person.circle.fill", width: mediumTileWidth)
                        Spacer()
                    }
                    VStack {
                        shortMedTile(width: mediumTileWidth)
                    }
                }
                .clipped()
                Spacer()
            }
        }
    }
}

func medTile(title: String, icon: String, width: CGFloat) -> some View {
    return MedTileContent(title: title, icon: icon, width: width)
}

fileprivate struct MedTileContent: View {
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
                    PillWithIconPlusShadow(title: title, icon: icon)
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

func shortMedTile(width: CGFloat) -> some View {
    return shortMedTileContent(width: width)
}

fileprivate struct shortMedTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat

    var body: some View {
        // Using Method 1: ZStack with bottom alignment
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red)
                .frame(width: width, height: width * 0.325)
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

#Preview {
    mediumTileTests()
}
