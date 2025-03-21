//
//  LastWeekView.swift
//  Wagevo
//
//  Created by Carter Hammond on [Today’s Date]
//

import SwiftUI
import Charts

struct LastWeekView: View {
    private let wagePerHour: Double = 15.0
    private var lastWeekInterval: DateInterval {
        let calendar = Calendar.current
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!
        let start = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start)!
        return DateInterval(start: start, end: currentWeek.start)
    }
    
    private var weekShifts: [Shift] {
        getPreviousShifts().filter { $0.startTime >= lastWeekInterval.start && $0.startTime < lastWeekInterval.end }
    }
    
    private var totalEarnings: Double {
        weekShifts.reduce(0.0) { $0 + ($1.duration / 3600.0 * wagePerHour) }
    }
    
    private var averageShift: Double {
        weekShifts.isEmpty ? 0.0 : weekShifts.reduce(0.0) { $0 + ($1.duration / 3600.0) } / Double(weekShifts.count)
    }
    
    private var shiftCount: Int { weekShifts.count }
    
    private var dailyData: [DailyEarnings] {
        var results: [DailyEarnings] = []
        let calendar = Calendar.current
        var current = lastWeekInterval.start
        while current < lastWeekInterval.end {
            let next = calendar.date(byAdding: .day, value: 1, to: current)!
            let dayShifts = weekShifts.filter { $0.startTime >= current && $0.startTime < next }
            let dayTotal = dayShifts.reduce(0.0) { $0 + ($1.duration / 3600.0 * wagePerHour) }
            let dayName = DateFormatter().shortWeekdaySymbols[calendar.component(.weekday, from: current) - 1]
            results.append(DailyEarnings(day: dayName, earnings: dayTotal))
            current = next
        }
        return results
    }
    
    var body: some View {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let mediumTileWidth = usableWidth
                let smallTileWidth = (usableWidth - 14) / 2

                ScrollView {
                    VStack(spacing: 16) {
                        // Tile 1: Large Tile (Chart) at the TOP
                        NavigationLink {
                            // Detail view if needed
                        } label: {
                            largeTile(title: "Daily Earnings", icon: "chart.bar.fill", width: mediumTileWidth)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        Chart(dailyData) { item in
                                            BarMark(
                                                x: .value("Day", item.day),
                                                y: .value("Earnings", item.earnings)
                                            )
                                            .foregroundStyle(Color("AccentColor"))
                                        }
                                        .frame(width: mediumTileWidth * 0.85, height: mediumTileWidth * 0.75)
                                        .padding()
                                        .padding(.bottom, 5)
                                    }
                                )
                        }
                        
                        // Tile 2: Medium Tile for Total Earnings
                        NavigationLink {
                            // Detail view if needed
                        } label: {
                            mediumTile(title: "Total Earnings", icon: "dollarsign.circle.fill", width: mediumTileWidth)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Text(formatCurrencyShort(totalEarnings))
                                                .font(.largeTitle)
                                                .fontWeight(.heavy)
                                                .foregroundColor(Color("AccentColor"))
                                                .padding()
                                            Spacer()
                                        }
                                    }
                                )
                        }
                        
                        // Tile 3: Row with small tile and a single xSmallTile
                        HStack(spacing: 14) {
                            NavigationLink {
                                // Detail view if needed
                            } label: {
                                smallTile(title: "Avg Shift", icon: "clock", width: smallTileWidth)
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Text(String(format: "%.2fh", averageShift))
                                                    .font(.title)
                                                    .fontWeight(.heavy)
                                                    .foregroundColor(Color("AccentColor"))
                                                Spacer()
                                            }
                                        }
                                        .padding()
                                    )
                            }
                            
                            NavigationLink {
                                // Detail view if needed
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
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Last Week")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LastWeekView()
}
