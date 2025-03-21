//
//  Available Balance.swift
//  Wagevo
//
//  Created by Carter Hammond on 3/15/25.
//

import SwiftUI

struct Available_Balance: View {
    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)

            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth
            
            VStack {
                ZStack {
                    mediumTile(title: "Available Balance", icon: "dollar.circle", width: mediumTileWidth)
                    VStack {
                        HStack {
                            Text("Available Balance")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                    }
                }
                
            }
            .padding()
        }
        
        Spacer()
    }
}

#Preview {
    Available_Balance()
}
