//
//  BankView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI
import Charts

struct BankView: View {
    @State private var animatedBalance: Double = 0 // ✅ Starts at 0 for animation
    private let realBalance: Double = 850.71 // ✅ Replace with actual balance source
    @State private var lastHapticStep: Double = 0 // ✅ Track last haptic trigger step


    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.05
            let usableWidth = geometry.size.width - (horizontalPadding * 2)

            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth

            ScrollView {
                VStack {
                    // ✅ Available Balance Tile with Rolling Animation
                    NavigationLink(destination: DebitCardView()) {
                        ZStack {
                            VStack {
                                mediumTile(title: "Available Balance", icon: "dollarsign.circle.fill", width: mediumTileWidth)
                            }
                            .padding(.vertical)

                            VStack {
                                Spacer()
                                HStack {
                                    Text("\(formattedBalance(animatedBalance))") // ✅ Uses rolling animation
                                        .font(.system(size: mediumTileWidth * 0.19, weight: .heavy))
                                        .foregroundColor(Color("AccentColor"))
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.bottom, 15)
                                .padding(.top, 35)
                            }
                            .padding()
                        }
                        .frame(width: mediumTileWidth, height: 180)
                        .padding(.top)
                    }
                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                    .contextMenu {
                        NavigationLink(destination: DebitCardView()) {
                            Label("View Balance Details", systemImage: "creditcard")
                        }
                    }
                    .onAppear {
                        rollBalance() // ✅ Triggers the animation
                    }

                    // ✅ Transactions Tile
                    NavigationLink(destination: DebitCardView()) {
                        ZStack {
                            VStack {
                                mediumTile(title: "Transactions", icon: "arrow.left.arrow.right.circle.fill", width: mediumTileWidth)
                            }
                            .padding(.vertical)

                            VStack {
                                HStack {
                                    Text("Dec 17").fontWeight(.semibold)
                                    Spacer()
                                    Text("2 hrs, 28 min").fontWeight(.light)
                                }
                                .padding(.bottom, 5)
                                .padding(.top, 35)
                                HStack {
                                    Text("Jan 12").fontWeight(.semibold)
                                    Spacer()
                                    Text("4 hrs, 16 min").fontWeight(.light)
                                }
                                .padding(.vertical, 6)
                                HStack {
                                    Text("Jan 22").fontWeight(.semibold)
                                    Spacer()
                                    Text("4 hrs, 23 min").fontWeight(.light)
                                }
                                .padding(.vertical, 6)
                            }
                            .padding()
                            .padding(.horizontal, 4)
                            .padding(.top, 10)
                        }
                        .frame(width: mediumTileWidth, height: 180)
                        .padding(.top)
                    }
                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })

                    // ✅ Small and Extra Small Tiles
                    HStack {
                        // Small Tile (Debit Card)
                        NavigationLink(destination: DebitView()) {
                            ZStack {
                                VStack {
                                    smallTile(title: "Debit", icon: "creditcard.circle.fill", width: smallTileWidth)
                                }
                                VStack {
                                    HStack {
                                        Text("Active")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("AccentColor"))
                                            .minimumScaleFactor(0.8)
                                            .lineLimit(1)
                                            .padding(.leading, 6)
                                        Spacer()
                                    }
                                    .padding()
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Last Transaction: Cupbop -  $12.87")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                            .padding(.trailing, 5.0)
                                    }
                                }
                            }
                            .clipped()
                        }
                        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })

                        Spacer()

                        // Extra Small Tiles
                        VStack(spacing: 12) {
                            ForEach(["Deposits", "Withdrawals"], id: \.self) { title in
                                NavigationLink(destination: DebitCardView()) {
                                    ZStack {
                                        VStack {
                                            xSmallTile(title: title, width: smallTileWidth)
                                        }
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Text(title == "Deposits" ? "$1.5K" : "$750")
                                                    .font(.title2)
                                                    .fontWeight(.heavy)
                                                    .foregroundColor(Color("AccentColor"))
                                                    .padding()
                                                    .padding(.leading, 3.0)
                                                Spacer()
                                            }
                                        }
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("Last 30 days")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .padding(.bottom, 3.0)
                                                    .padding()
                                                    .padding(.trailing, 5.0)
                                            }
                                        }
                                    }
                                    .clipped()
                                }
                                .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                            }
                        }
                    }
                    .padding(.vertical)

                    // ✅ Upcoming Shifts Tile
                    NavigationLink(destination: DebitCardView()) {
                        ZStack {
                            VStack {
                                mediumTile(title: "Recent Spending", icon: "stopwatch.fill", width: mediumTileWidth)
                            }
                            .padding(.vertical)
                            
                            VStack {
                                SpendingBarChart()
                                    .frame(height: 100) // ✅ Adjust height as needed
                                    .padding(.horizontal, 12)
                                    .padding(.top, 55)
                            }
                        }
                        .frame(width: mediumTileWidth, height: 180)
                        .padding(.vertical, 5)
                    }
                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                }
                .padding(.horizontal, horizontalPadding)
            }
            .navigationTitle("Bank")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    // ✅ Spending Graph View
    struct SpendingBarChart: View {
        let spendingData: [(day: String, amount: Double)] = [
            ("Mon", 12.5), ("Tue", 28.7), ("Wed", 5.4), ("Thu", 19.9),
            ("Fri", 45.3), ("Sat", 32.8), ("Sun", 15.6)
        ]
        
        var body: some View {
            Chart {
                ForEach(spendingData, id: \.day) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(Color("AccentColor"))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }

    // ✅ Function to Provide Haptic Feedback
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }

    // ✅ Number Formatter for Currency Display
    private func formattedBalance(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    // ✅ Rolling Animation with Synced Haptic Feedback
    private func rollBalance() {
        animatedBalance = 0 // ✅ Reset animation
        lastHapticStep = 0 // ✅ Reset haptic tracker

        Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { timer in
            if animatedBalance < realBalance {
                animatedBalance += (realBalance / 50) // ✅ Smooth increments

                // ✅ Trigger haptic feedback every $50 step
                if animatedBalance - lastHapticStep >= 50 {
                    provideRollingHaptic()
                    lastHapticStep = animatedBalance
                }
            } else {
                animatedBalance = realBalance // ✅ Ensures exact match
                timer.invalidate() // ✅ Stops when finished
            }
        }
    }

    // ✅ Soft Haptic Feedback for Rolling Effect
    private func provideRollingHaptic() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid) // ✅ Soft rolling taps
        feedbackGenerator.impactOccurred()
    }
}

#Preview {
    BankView()
}
