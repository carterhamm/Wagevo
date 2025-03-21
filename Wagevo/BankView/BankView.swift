//
//  BankView.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/3/25
//

import SwiftUI
import Charts

// MARK: - BankingTileView
struct BankingTileView: View {
    var width: CGFloat // Accepts width from BankView
    var transNamespace: Namespace.ID  // Added for navigation transition

    @State private var animatedBalance: Double = 0
    private let wagePerHour: Double = 15.0
    @State private var lastHapticStep: Double = 0

    @Environment(\.colorScheme) var colorScheme

    // Now compute realBalance based on stored shifts and expenses
    private var realBalance: Double {
        let shifts = getPreviousShifts()
        let totalEarnings = shifts.reduce(into: 0.0) { sum, shift in
            // Removed shift.earnings reference, now compute from duration only
            sum += (shift.duration / 3600.0 * wagePerHour)
        }
        let totalExpenses = getPreviousExpenses().reduce(into: 0.0) { sum, expense in
            sum += expense.amount
        }
        return totalEarnings - totalExpenses
    }

    var body: some View {
        ZStack {
            // Top tile
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(darkGray) : Color.white)

            // Content inside the tile
            VStack(alignment: .leading) {
                HStack {
                    pillWithIcon(title: "Available Balance", icon: "dollarsign.circle.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 4)
                }
                Spacer()
                Text(formattedBalance(animatedBalance))
                    .font(.system(size: width * 0.16, weight: .heavy))
                    .foregroundColor(Color("AccentColor"))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .padding(.leading, 3)
                    .padding(.bottom, 1)
                    .shadow(radius: 1)
                // Updated NavigationLink for TransferView with Zoom Transition:
                NavigationLink {
                    TransferView()
                        .navigationTransition(.zoom(sourceID: "transferTile", in: transNamespace))
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("AccentColor"))
                        Text("Transfer")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .frame(width: width - 18, height: 75)
                    .matchedTransitionSource(id: "transferTile", in: transNamespace)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 10)
        }
        // Make the tile 5% shorter than before:
        .frame(width: width, height: width * 0.68 * 0.95)
        // Add the consistent thin border:
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear { rollBalance() }
    }

    private func rollBalance() {
        animatedBalance = 0
        lastHapticStep = 0
        Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { timer in
            if animatedBalance < realBalance {
                animatedBalance += (realBalance / 50)
                if animatedBalance - lastHapticStep >= 50 {
                    provideRollingHaptic()
                    lastHapticStep = animatedBalance
                }
            } else {
                animatedBalance = realBalance
                timer.invalidate()
            }
        }
    }

    private func provideRollingHaptic() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
        feedbackGenerator.impactOccurred()
    }
}

// Helper: Currency Formatter
private func formattedBalance(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
}

// Helper: Pill with Icon
private func pillWithIcon(title: String, icon: String) -> some View {
    HStack {
        Image(systemName: icon)
            .foregroundColor(.white)
            .symbolRenderingMode(.hierarchical)
        Text(title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .background(
        RoundedRectangle(cornerRadius: 15)
            .fill(Color("AccentColor"))
    )
}

// MARK: - BankView
struct BankView: View {
    @State private var animatedBalance: Double = 0 // For balance animation
    private let wagePerHour: Double = 15.0
    @State private var lastHapticStep: Double = 0

    @Environment(\.colorScheme) var colorScheme

    // Manage showing the transactions view with a bool (used for binding in TransactionsGesture)
    @State private var showTransactions = false

    // A namespace for our zoom transitions
    @Namespace private var transNamespace

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)

            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth

            ZStack {
                (colorScheme == .light ? appleLightGray : Color.black)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 13) {
                        // 1) Available Balance Tile with zoom transition
                        NavigationLink {
                            CashOutView()
                                .navigationTransition(.zoom(sourceID: "bankingTile", in: transNamespace))
                        } label: {
                            BankingTileView(width: mediumTileWidth, transNamespace: transNamespace)
                                .frame(width: mediumTileWidth)
                                .matchedTransitionSource(id: "bankingTile", in: transNamespace)
                        }
                        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                        .contextMenu {
                            NavigationLink {
                                DebitCardView()
                                    .navigationTransition(.zoom(sourceID: "balanceDetails", in: transNamespace))
                            } label: {
                                Label("View Balance Details", systemImage: "creditcard")
                                    .matchedTransitionSource(id: "balanceDetails", in: transNamespace)
                            }
                        }
                        .onAppear {
                            rollBalance()
                        }
                        .buttonStyle(BouncyButtonStyle())

                        // 2) Transactions Tile as NavigationLink with zoom transition, haptic, and context menu
                        NavigationLink {
                            TransactionsGesture(showTransactions: $showTransactions, namespace: transNamespace)
                                .navigationTransition(.zoom(sourceID: "transactionsTile", in: transNamespace))
                        } label: {
                            ZStack {
                                VStack {
                                    mediumTile(
                                        title: "Transactions",
                                        icon: "arrow.left.arrow.right.circle.fill",
                                        width: mediumTileWidth
                                    )
                                }
                                VStack {
                                    // Wrap the inner text in a VStack with the proper foregroundColor:
                                    VStack {
                                        HStack {
                                            Text("Dec 17")
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text("2 hrs, 28 min")
                                                .fontWeight(.regular)
                                        }
                                        .padding(.bottom, 5)
                                        .padding(.top, 35)
                                        HStack {
                                            Text("Jan 12")
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text("4 hrs, 16 min")
                                                .fontWeight(.regular)
                                        }
                                        .padding(.vertical, 6)
                                        HStack {
                                            Text("Jan 22")
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text("4 hrs, 23 min")
                                                .fontWeight(.regular)
                                        }
                                        .padding(.vertical, 6)
                                    }
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                .padding()
                                .padding(.horizontal, 4)
                                .padding(.top, 10)
                            }
                            .matchedTransitionSource(id: "transactionsTile", in: transNamespace)
                        }
                        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                        .contextMenu {
                            NavigationLink {
                                TransactionsGesture(showTransactions: $showTransactions, namespace: transNamespace)
                                    .navigationTransition(.zoom(sourceID: "transactionsTile", in: transNamespace))
                            } label: {
                                Label("View Transactions", systemImage: "arrow.left.arrow.right.circle.fill")
                                    .matchedTransitionSource(id: "transactionsTile", in: transNamespace)
                            }
                        }

                        // 3) Small and Extra Small Tiles HStack (Debit Widget)
                        HStack {
                            NavigationLink {
                                DebitView()
                                    .navigationTransition(.zoom(sourceID: "debitTile", in: transNamespace))
                            } label: {
                                ZStack {
                                    VStack {
                                        smallTile(
                                            title: "Debit",
                                            icon: "creditcard.circle.fill",
                                            width: smallTileWidth
                                        )
                                    }
                                    VStack(spacing: 4) {
                                        Spacer()
                                        // Suggestions: Consider displaying one of the following above "Active":
                                        // • "Last Purchase: Cupbop - $12.87"
                                        // • "Recent Transaction"
                                        // • "Pending Charges"
                                        // You might replace the static text below with dynamic data if available.
                                        HStack {
                                            Text("Last Transaction: Cupbop - $12.87")
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 5)
                                                .lineLimit(2)
                                            Spacer()
                                        }
                                        HStack {
                                            Text("Active")
                                                .font(.system(size: mediumTileWidth * 0.10, weight: .heavy))
                                                .foregroundColor(Color("AccentColor"))
                                                .padding(.leading, 3)
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                }
                                .clipped()
                                .matchedTransitionSource(id: "debitTile", in: transNamespace)
                            }
                            .buttonStyle(BouncyButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })

                            Spacer()

                            VStack(spacing: 12) {
                                // Compute deposit and spending sums for last 30 days:
                                let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                                let last30Shifts = getPreviousShifts().filter { $0.startTime >= thirtyDaysAgo }
                                let depositValue = last30Shifts.reduce(0.0) { sum, shift in
                                    sum + (shift.duration / 3600.0 * wagePerHour)
                                }

                                let last30Expenses = getPreviousExpenses().filter { $0.date >= thirtyDaysAgo }
                                let spendingValue = last30Expenses.reduce(0.0) { sum, expense in
                                    expense.isIncome ? sum : sum + expense.amount
                                }

                                ForEach(["Deposits", "Spending"], id: \.self) { title in
                                    NavigationLink {
                                        DebitCardView()
                                            .navigationTransition(.zoom(sourceID: "tile\(title)", in: transNamespace))
                                    } label: {
                                        ZStack {
                                            VStack {
                                                xSmallTile(title: title, width: smallTileWidth)
                                            }
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Text(
                                                        title == "Deposits"
                                                        ? shortMoneyString(depositValue)
                                                        : shortMoneyString(spendingValue)
                                                    )
                                                    .font(.title2)
                                                    .fontWeight(.heavy)
                                                    .foregroundColor(Color("AccentColor"))
                                                    .padding()
                                                    .padding(.leading, 5.0)
                                                    Spacer()
                                                }
                                            }
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Text("Last 30d")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                        .padding(.bottom, 3.0)
                                                        .padding()
                                                        .padding(.trailing, 5.0)
                                                }
                                            }
                                        }
                                        .clipped()
                                        .matchedTransitionSource(id: "tile\(title)", in: transNamespace)
                                        .padding(.leading, 0.001)
                                    }
                                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                                }
                            }
                        }
                        .padding(.top, 5)

                        // 4) Recent Spending Tile with top border fixed
                        NavigationLink {
                            DebitCardView()
                                .navigationTransition(.zoom(sourceID: "recentSpendingTile", in: transNamespace))
                        } label: {
                            ZStack {
                                VStack {
                                    mediumTile(
                                        title: "Recent Spending",
                                        icon: "stopwatch.fill",
                                        width: mediumTileWidth
                                    )
                                }
                                VStack {
                                    SpendingBarChart()
                                        .frame(width: mediumTileWidth * 0.9, height: mediumTileWidth * 0.25)
                                        .padding(.horizontal, 12)
                                        .padding(.top, 55) // Consider reducing this value if the border is obscured.
                                        .padding(.bottom, 12)
                                }
                            }
                            .frame(width: mediumTileWidth, height: 185)
                            .padding(.bottom, 10)
                            .padding(.top, 5)
                            .matchedTransitionSource(id: "recentSpendingTile", in: transNamespace)
                        }
                        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .navigationTitle("Bank")
            }
        }
    }

    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }

    private func rollBalance() {
        animatedBalance = 0
        lastHapticStep = 0
        Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { timer in
            if animatedBalance < realBalance() {
                animatedBalance += (realBalance() / 50)
                if animatedBalance - lastHapticStep >= 50 {
                    provideHapticFeedback()
                    lastHapticStep = animatedBalance
                }
            } else {
                animatedBalance = realBalance()
                timer.invalidate()
            }
        }
    }
    
    // Helper function to compute real balance here as well for rollBalance animation
    private func realBalance() -> Double {
        let shifts = getPreviousShifts()
        let totalEarnings = shifts.reduce(into: 0.0) { sum, shift in
            // Removed shift.earnings reference, now compute from duration only
            sum += (shift.duration / 3600.0 * wagePerHour)
        }
        let totalExpenses = getPreviousExpenses().reduce(into: 0.0) { sum, expense in
            sum += expense.amount
        }
        return totalEarnings - totalExpenses
    }
}

// Spending Graph View - Now using real expense data from the past week
struct SpendingBarChart: View {
    var spendingData: [(day: String, amount: Double)] {
        var data: [String: Double] = [:]
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let expenses = getPreviousExpenses().filter { $0.date >= sevenDaysAgo }
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let weekdaySymbols = formatter.shortWeekdaySymbols ?? []
        for expense in expenses {
            let weekdayIndex = calendar.component(.weekday, from: expense.date) - 1
            let dayName = weekdaySymbols[weekdayIndex]
            data[dayName, default: 0.0] += expense.amount
        }
        // Return data in the order of the weekday symbols
        return weekdaySymbols.map { day in
            (day: day, amount: data[day] ?? 0.0)
        }
    }
    
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
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
}

// MARK: - Helper for the xSmallTiles
/// Show up to 4 characters after `$`. For example: `$1234`, `$12.3`, `$9999` if >= 10k, etc.
/// Formats a monetary value into a short string with roughly 4 digits (excluding the decimal point) after the '$'.
/// Examples: $41.2K, $589, $32.64
private func shortMoneyString(_ value: Double) -> String {
    if value >= 1000 {
        let thousands = value / 1000
        let integerPart = Int(thousands)
        let integerDigits = String(integerPart).count
        // Allow up to 4 digits in total (excluding the decimal point and the 'K')
        let decimalsAllowed = max(0, 4 - integerDigits)
        let formatString = "%.\(decimalsAllowed)f"
        let formatted = String(format: formatString, thousands)
        let trimmed = formatted.replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
        return "$" + trimmed + "K"
    } else {
        let integerPart = Int(value)
        let integerDigits = String(integerPart).count
        let decimalsAllowed = max(0, 4 - integerDigits)
        if decimalsAllowed == 0 {
            return "$" + String(Int(value))
        } else {
            let formatString = "%.\(decimalsAllowed)f"
            let formatted = String(format: formatString, value)
            let trimmed = formatted.replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
            return "$" + trimmed
        }
    }
}

// MARK: - Preview
struct BankView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BankView()
        }
    }
}
