//
//  TransferView.swift
//  Wagevo
//
//  Created by Carter Hammond on 3/15/25.
//

import SwiftUI

struct LoadingView: View {
    let circleCount = 3
    @State private var activeIndex: Int = 0
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .offset(y: activeIndex == index ? -20 : 5)
                    .animation(.easeInOut(duration: 0.5), value: activeIndex)
            }
        }
        .foregroundColor(Color("AccentColor"))
        .onAppear { startAnimation() }
    }
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            activeIndex = (activeIndex + 1) % circleCount
        }
    }
}

struct TransferView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var inputDigits: String = "0"
    @State private var showConfirm: Bool = true
    @FocusState private var isFocused: Bool
    @State private var isTransferring: Bool = false
    @State private var transferSuccessful: Bool = false
    
    private var displayedAmount: String {
        let cents = Int(inputDigits) ?? 0
        let dollars = Double(cents) / 100.0
        return "$" + String(format: "%.2f", dollars)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("", text: Binding(
                get: { displayedAmount },
                set: { newValue in
                    let digits = newValue.filter { $0.isNumber }
                    if inputDigits == "0" {
                        if let newDigit = digits.last, newDigit != "0" {
                            inputDigits = String(newDigit)
                        }
                    } else {
                        if digits.count > inputDigits.count, let newDigit = digits.last {
                            inputDigits.append(newDigit)
                        } else if digits.count < inputDigits.count {
                            inputDigits = String(inputDigits.dropLast())
                            if inputDigits.isEmpty {
                                inputDigits = "0"
                            }
                        }
                    }
                }
            ))
            .font(.system(size: 70, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
            
            Text("Available: \(formattedBalance(computeAvailableBalance()))")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if showConfirm {
                Button {
                    showConfirm = false
                    isFocused = false
                } label: {
                    Text("Confirm Amount")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("AccentColor"))
                        .cornerRadius(30)
                }
            } else {
                ZStack {
                    Capsule()
                        .frame(maxWidth: isTransferring ? 55 : .infinity)
                        .frame(height: 55)
                        .foregroundStyle(transferSuccessful ? Color.green : Color("AccentColor"))
                    Text(transferSuccessful ? "Payment successful" : "Transfer")
                        .bold()
                        .foregroundColor(.white)
                        .scaleEffect(isTransferring ? 0 : 1)
                    LoadingView()
                        .scaleEffect(isTransferring ? 1 : 0)
                }
                .animation(.spring, value: isTransferring)
                .onTapGesture {
                    if !isTransferring {
                        isTransferring = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.spring) {
                                isTransferring = false
                                transferSuccessful = true
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .navigationTitle("Transfer")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func computeAvailableBalance() -> Double {
        let shifts = getPreviousShifts()
        let totalEarnings = shifts.reduce(0.0) { sum, shift in
            sum + (shift.duration / 3600.0 * 15.0)
        }
        let totalExpenses = getPreviousExpenses().reduce(0.0) { sum, expense in
            sum + expense.amount
        }
        return totalEarnings - totalExpenses
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

#Preview {
    TransferView()
}
