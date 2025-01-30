//
//  DebitCardView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/29/25.
//

import SwiftUI

struct DebitView: View {
    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "creditcard.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)
                    .foregroundStyle(.accent)
                    .padding(.top)
                
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .padding()
            }
        }
        .navigationTitle("Wageify Debit")
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}

#Preview {
    DebitView()
}
