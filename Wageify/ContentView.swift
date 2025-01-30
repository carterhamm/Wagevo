//
//  ContentView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("This is the main content.")
                    .padding()
            }
            .navigationTitle("Page Title") // Sets the title
            .toolbar {
                // Add items to the toolbar (navigation bar)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("Leading button tapped")
                    }) {
                        Image(systemName: "arrow.left")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Custom Header")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Trailing button tapped")
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
