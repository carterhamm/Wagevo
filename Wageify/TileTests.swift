//
//  TileTests.swift
//  Wageify
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI

struct TileTests: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 180, height: 180)
            VStack {
                HStack {
                    Text("Tile")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: 180, maxHeight: 180)
        .clipped()
    }
}

#Preview {
    TileTests()
}
