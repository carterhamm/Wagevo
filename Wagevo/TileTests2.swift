//
//  TileTests2.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/9/25.
//

import SwiftUI

struct TileTests2: View {
    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)
            // Match the calculation used in BankView:
            let smallTileWidth = (usableWidth - 14) / 2
            
            VStack {
                HStack {
                    Text("Hello, World!")
                        .font(.headline)
                }
                Spacer()
                // Pass in the computed smallTileWidth so the tile matches the size from BankView.
                xSmallTileTest(title: "Sample Title", width: smallTileWidth)
                Spacer()
            }
            .frame(width: geometry.size.width)
        }
    }
}

func xSmallTileTest(title: String, width: CGFloat) -> some View {
    return XSmallTileTestContent(title: title, width: width)
}

fileprivate struct XSmallTileTestContent: View {
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
                        .foregroundColor(Color.black)
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

#Preview {
    TileTests2()
}
