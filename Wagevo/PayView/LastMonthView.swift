//
//  LastMonthView.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/16/25.
//

import SwiftUI
import Charts

struct LastMonthView: View {
    private let wagePerHour: Double = 15.0
    private var lastMonthInterval: DateInterval {
        let calendar = Calendar.current
        let currentMonth = calendar.dateInterval(of: .month, for: Date())!
        let start = calendar.date(byAdding: .month, value: -1, to: currentMonth.start)!
        return DateInterval(start: start, end: currentMonth.start)
    }
    
    private var monthShifts: [Shift] {
        getPreviousShifts().filter { $0.startTime >= lastMonthInterval.start && $0.startTime < lastMonthInterval.end }
    }
    
    private var totalEarnings: Double {
        monthShifts.reduce(0.0) { $0 + ($1.duration / 3600.0 * wagePerHour) }
    }
    
    private var averageShift: Double {
        monthShifts.isEmpty ? 0.0 : monthShifts.reduce(0.0) { $0 + ($1.duration / 3600.0) } / Double(monthShifts.count)
    }
    
    private var shiftCount: Int { monthShifts.count }
    
    // Group shifts by week of month.
    private var weeklyData: [WeeklyEarnings] {
        let calendar = Calendar.current
        var grouped: [Int: Double] = [:]
        for shift in monthShifts {
            let week = calendar.component(.weekOfMonth, from: shift.startTime)
            grouped[week, default: 0.0] += shift.duration / 3600.0 * wagePerHour
        }
        return grouped.map { WeeklyEarnings(week: $0.key, earnings: $0.value) }
            .sorted { $0.week < $1.week }
    }
    
    var body: some View {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let mediumTileWidth = usableWidth
                let smallTileWidth = (usableWidth - 14) / 2
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Tile 1: Total Earnings (mediumTile)
                        NavigationLink {
                        } label: {
                            mediumTile(title: "Total Earnings", icon: "dollarsign.circle.fill", width: mediumTileWidth)
                                .overlay(
                                    HStack {
                                        Text(formatCurrencyShort(totalEarnings))
                                            .font(.headline)
                                            .foregroundColor(Color("AccentColor"))
                                            .padding()
                                        Spacer()
                                    }
                                )
                        }
                        
                        // Tile 2: Avg Shift and Shifts count (xSmall pair)
                        HStack(spacing: 14) {
                            NavigationLink {
                            } label: {
                                smallTile(title: "Avg Shift", icon: "clock", width: smallTileWidth)
                                    .overlay(
                                        Text(String(format: "%.2fh", averageShift))
                                            .font(.headline)
                                            .foregroundColor(Color("AccentColor"))
                                    )
                            }
                            
                            VStack(spacing: 14) {
                                NavigationLink {
                                } label: {
                                    xSmallTile(title: "Shifts", width: smallTileWidth)
                                        .overlay(
                                            Text("\(shiftCount)")
                                                .font(.headline)
                                                .foregroundColor(Color("AccentColor"))
                                        )
                                }
                                NavigationLink {
                                } label: {
                                    xSmallTile(title: "Shifts", width: smallTileWidth)
                                        .overlay(
                                            Text("\(shiftCount)")
                                                .font(.headline)
                                                .foregroundColor(Color("AccentColor"))
                                        )
                                }
                            }
                        }
                        
                        // Tile 3: Weekly Breakdown Chart (largeTile)
                        NavigationLink {
                        } label: {
                            largeTile(title: "Weekly Breakdown", icon: "chart.bar.fill", width: mediumTileWidth)
                                .overlay(
                                    Chart(weeklyData) { item in
                                        BarMark(
                                            x: .value("Week", "W\(item.week)"),
                                            y: .value("Earnings", item.earnings)
                                        )
                                        .foregroundStyle(Color("AccentColor"))
                                    }
                                    .padding(6)
                                )
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Last Month")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LastMonthView()
}
