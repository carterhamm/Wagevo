//
//  SwiftUIView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI

struct BoolClock: View {
    @State private var isToggled = false // Boolean to track toggle state

    var body: some View {
        VStack {
            // Toggle Button
            Button(action: {
                isToggled.toggle() // Toggle the Boolean value
            })
            {
                Text(isToggled ? "Clocked In" : "Clocked Out") // Display state
                    .fontWeight(.bold)
                    .frame(width: 180, height: 90)
                    .background(isToggled ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding()

            // Display current state (optional)
            Text("Current state: \(isToggled ? "ON" : "OFF")")
        }
    }
}

#Preview {
    BoolClock()
}
