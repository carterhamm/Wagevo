//
//  PayrollView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI

struct SwiftUIView: View {
    let shift: Shift
    var body: some View {
        VStack {
            GeometryReader { geometry in
                // Use 4% horizontal padding.
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                // mediumTileWidth is defined as the full usable width.
                let mediumTileWidth = usableWidth
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TransactionsShiftTile(shift: shift, width: mediumTileWidth)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

fileprivate struct TransactionsShiftTile: View {
    let shift: Shift
    let width: CGFloat
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let dateString = formattedShiftDate(for: shift.startTime)
        let durationText = formatDuration(shift.duration)
        let timeRangeText = "(\(formattedTime(shift.startTime)) - \(formattedTime(shift.endTime)))"
        let earnings = (shift.duration / 3600.0) * 15.0

        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(darkGray) : Color.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.top, 15)
                        .padding(.leading, 12)
                    Spacer()
                    Text("\(durationText) \(timeRangeText)")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom, 15)
                        .padding(.leading, 12)
                }
                Spacer()
                VStack {
                    Spacer()
                    Text("$\(String(format: "%.2f", earnings))")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.white)
                        .padding(.trailing, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 30) // Create a rounded rectangle with a corner radius of 15
                                .fill(Color.accentColor) // Fill the rectangle with pink
                                .frame(height: 44)
                                .padding(.horizontal, -10)
                                .offset(x: -5)
                        )
                    Spacer()
                }
                .padding(.vertical)
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 5)
        }
        .frame(width: width, height: 80)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.vertical, 7)
    }
}

private func formattedShiftDate(for date: Date) -> String {
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: Date())
    let shiftYear = calendar.component(.year, from: date)
    let formatter = DateFormatter()
    formatter.dateFormat = shiftYear == currentYear ? "EEE, MMM d" : "EEE, MMM d, yyyy"
    return formatter.string(from: date)
}

private func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: date)
}

private func formatDuration(_ duration: TimeInterval) -> String {
    let totalSeconds = Int(duration)
    let hrs = totalSeconds / 3600
    let mins = (totalSeconds % 3600) / 60
    if hrs > 0 && mins > 0 {
        return "\(hrs)h \(mins)m"
    } else if hrs > 0 {
        return "\(hrs)h"
    } else {
        return "\(mins)m"
    }
}

#Preview {
    let now = Date()
    let sampleShift = Shift(
        shift_id: "sampleShiftId",
        startTime: now,
        endTime: Calendar.current.date(byAdding: .hour, value: 8, to: now)!,
        duration: 8 * 3600,
        user_id: "sampleUserId"
    )
    SwiftUIView(shift: sampleShift)
}
