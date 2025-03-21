//
//  DebitView.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/15/25
//

import SwiftUI
import Charts

// MARK: - Data Models & Sample Data

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let day: String
    let date: Date
}

let sampleTransactions: [Transaction] = [
    Transaction(title: "Coffee", amount: 3.50, day: "Mon", date: Date()),
    Transaction(title: "Lunch", amount: 12.00, day: "Tue", date: Date()),
    Transaction(title: "Groceries", amount: 45.00, day: "Wed", date: Date()),
    Transaction(title: "Gas", amount: 25.00, day: "Thu", date: Date()),
    Transaction(title: "Dinner", amount: 30.00, day: "Fri", date: Date())
]

let sampleTransactionList: [Transaction] = [
    Transaction(title: "Coffee Shop", amount: 3.50, day: "Mon", date: Date()),
    Transaction(title: "Restaurant", amount: 25.00, day: "Tue", date: Date()),
    Transaction(title: "Supermarket", amount: 65.00, day: "Wed", date: Date()),
    Transaction(title: "Online Purchase", amount: 120.00, day: "Thu", date: Date()),
    Transaction(title: "Gas Station", amount: 40.00, day: "Fri", date: Date())
]

// MARK: - DebitView

struct DebitView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Large Debit Card Display
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.accentColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                            .frame(height: width * 0.6)
                            .shadow(radius: 10)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer()
                            Text("Wagevo Debit")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("**** **** **** 1234")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            HStack {
                                Text("Exp: 12/25")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("LeBron James")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(width * 0.08)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // MARK: - Current Balance & Chart with Large Tile Background
                    ZStack {
                        // “Large tile” background behind the balance & chart:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? darkGray : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
                            )
                        VStack(alignment: .center, spacing: 8) {
                            Text("Current Balance")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text("$1,234.56")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            if #available(iOS 16.0, *) {
                                Chart {
                                    ForEach(sampleTransactions) { tx in
                                        BarMark(
                                            x: .value("Day", tx.day),
                                            y: .value("Amount", tx.amount)
                                        )
                                        .foregroundStyle(Color("AccentColor"))
                                    }
                                }
                                .frame(height: width * 0.5)
                                .padding(.horizontal)
                            } else {
                                Text("Chart unavailable")
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)

                    // MARK: - Recent Transactions Tiles (Centered)
                    VStack(alignment: .center, spacing: 8) {
                        Text("Recent Transactions")
                            .font(.headline)
                        ForEach(sampleTransactionList) { transaction in
                            SystemTransactionTile(transaction: transaction, width: width * 0.9)
                        }
                    }
                    .frame(maxWidth: .infinity)  // Centers the content horizontally
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Wagevo Debit")
        .navigationBarTitleDisplayMode(.inline)
        .background(colorScheme == .dark ? Color.black : Color(UIColor.systemGray6))
    }
}

// MARK: - SystemTransactionTile

struct SystemTransactionTile: View {
    let transaction: Transaction
    let width: CGFloat
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                    .foregroundColor(Color("AccentColor"))
                    .multilineTextAlignment(.center)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(String(format: "%.2f", transaction.amount))")
                .font(.title2)
                .bold()
                .foregroundColor(Color("AccentColor"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
                )
        )
        .frame(width: width, height: 80)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DebitView()
    }
}
