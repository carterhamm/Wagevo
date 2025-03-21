//
//  PayViewSubviews.swift
//  Wagevo
//
//  Created by Carter Hammond on [Today’s Date]
//

import SwiftUI
import Charts

// MARK: - Data Models for Charts

struct DailyEarnings: Identifiable {
    let id = UUID()
    let day: String
    let earnings: Double
}

struct WeeklyEarnings: Identifiable {
    let id = UUID()
    let week: Int
    let earnings: Double
}

struct MonthlyEarnings: Identifiable {
    let id = UUID()
    let month: String
    let earnings: Double
}

// MARK: - EarningsView
/// Displays current week earnings with 4 tiles.
struct EarningsView: View {
    private let wagePerHour: Double = 15.0
    
    // Current week interval
    private var currentWeekInterval: DateInterval {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
    }
    
    // Filter shifts in current week.
    private var weekShifts: [Shift] {
        getPreviousShifts().filter { $0.startTime >= currentWeekInterval.start && $0.startTime < currentWeekInterval.end }
    }
    
    // Total earnings for current week.
    private var totalEarnings: Double {
        weekShifts.reduce(0.0) { $0 + ($1.duration / 3600.0 * wagePerHour) }
    }
    
    // Average shift (in hours) for current week.
    private var averageShift: Double {
        weekShifts.isEmpty ? 0.0 : weekShifts.reduce(0.0) { $0 + ($1.duration / 3600.0) } / Double(weekShifts.count)
    }
    
    // Count of shifts.
    private var shiftCount: Int { weekShifts.count }
    
    // Daily earnings data for chart.
    private var dailyData: [DailyEarnings] {
        var results: [DailyEarnings] = []
        let calendar = Calendar.current
        var current = currentWeekInterval.start
        while current < currentWeekInterval.end {
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

                let smallTileWidth = (usableWidth - 14) / 2
                let mediumTileWidth = usableWidth
                
                ScrollView {
                    VStack {
                        // Tile 1: Total Earnings (mediumTile)
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
                                    .padding()
                                )
                        }
                        
                        // Tile 2: Average Shift (smallTile)
                        HStack {
                            NavigationLink {
                            } label: {
                                smallTile(title: "Avg Shift", icon: "clock", width: smallTileWidth)
                                    .overlay(
                                        Text(String(format: "%.2fh", averageShift))
                                            .font(.headline)
                                            .foregroundColor(Color("AccentColor"))
                                    )
                            }
                            
                            // Tile 3: Shifts Count (xSmallTile)
                            VStack {
                                NavigationLink {
                                } label: {
                                    xSmallTile(title: "Shifts", width: smallTileWidth)
                                        .overlay(
                                            Text("\(shiftCount)")
                                                .font(.headline)
                                                .foregroundColor(Color("AccentColor"))
                                        )
                                }
                                
                                // Tile 3: Shifts Count (xSmallTile)
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
                        
                        // Tile 4: Daily Earnings Chart (largeTile)
                        NavigationLink {
                        } label: {
                            largeTile(title: "Daily Earnings", icon: "chart.bar.fill", width: mediumTileWidth)
                                .overlay(
                                    Chart(dailyData) { item in
                                        BarMark(
                                            x: .value("Day", item.day),
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
            .navigationTitle("Earnings")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - YTDView
/// Displays year-to-date earnings with 4 tiles.
struct YTDView: View {
    private let wagePerHour: Double = 15.0
    private var startOfYear: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
    }
    
    private var ytdShifts: [Shift] {
        getPreviousShifts().filter { $0.startTime >= startOfYear && $0.startTime <= Date() }
    }
    
    private var totalEarnings: Double {
        ytdShifts.reduce(0.0) { $0 + ($1.duration / 3600.0 * wagePerHour) }
    }
    
    private var monthlyData: [MonthlyEarnings] {
        let calendar = Calendar.current
        var grouped: [Int: Double] = [:]
        for shift in ytdShifts {
            let month = calendar.component(.month, from: shift.startTime)
            grouped[month, default: 0.0] += shift.duration / 3600.0 * wagePerHour
        }
        let currentMonth = calendar.component(.month, from: Date())
        var results: [MonthlyEarnings] = []
        let formatter = DateFormatter()
        let monthSymbols = formatter.shortMonthSymbols ?? []
        for month in 1...currentMonth {
            let earnings = grouped[month] ?? 0.0
            results.append(MonthlyEarnings(month: monthSymbols[month - 1], earnings: earnings))
        }
        return results
    }
    
    // Compute average monthly earnings.
    private var averageMonthly: Double {
        let data = monthlyData
        return data.isEmpty ? 0.0 : data.reduce(0.0) { $0 + $1.earnings } / Double(data.count)
    }
    
    // Find best month.
    private var bestMonth: MonthlyEarnings? {
        monthlyData.max { $0.earnings < $1.earnings }
    }
    
    var body: some View {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let tileWidth = (usableWidth - 14) / 2
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        
                        // Tile 1: Total YTD Earnings
                        NavigationLink {
                        } label: {
                            mediumTile(title: "Total YTD", icon: "dollarsign.circle.fill", width: tileWidth)
                                .overlay(
                                    Text(formatCurrencyShort(totalEarnings))
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                )
                        }
                        
                        // Tile 2: Average Monthly
                        NavigationLink {
                        } label: {
                            smallTile(title: "Avg Monthly", icon: "chart.bar.doc.horizontal.fill", width: tileWidth)
                                .overlay(
                                    Text(formatCurrencyShort(averageMonthly))
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                )
                        }
                        
                        // Tile 3: Best Month
                        NavigationLink {
                        } label: {
                            xSmallTile(title: "Best Month", width: tileWidth)
                                .overlay(
                                    Text(bestMonth != nil ? bestMonth!.month : "-")
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                )
                        }
                        
                        // Tile 4: YTD Line Chart
                        NavigationLink {
                        } label: {
                            largeTile(title: "YTD Trend", icon: "chart.line.uptrend.xyaxis", width: tileWidth)
                                .overlay(
                                    Chart(monthlyData) { item in
                                        LineMark(
                                            x: .value("Month", item.month),
                                            y: .value("Earnings", item.earnings)
                                        )
                                        PointMark(
                                            x: .value("Month", item.month),
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
            .navigationTitle("Year-to-Date")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - OvertimeView
/// Displays current week overtime details with 4 tiles.
struct OvertimeView: View {
    private let wagePerHour: Double = 15.0
    // Overtime: any shift hours over 8.
    private var currentWeekInterval: DateInterval {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
    }
    
    private var weekShifts: [Shift] {
        getPreviousShifts().filter { $0.startTime >= currentWeekInterval.start && $0.startTime < currentWeekInterval.end }
    }
    
    // Total overtime hours (sum of max(0, hours-8)).
    private var totalOvertimeHours: Double {
        weekShifts.reduce(0.0) { total, shift in
            let hours = shift.duration / 3600.0
            return total + max(0, hours - 8)
        }
    }
    
    // Overtime earnings: overtime hours * wage * 1.5.
    private var overtimeEarnings: Double {
        totalOvertimeHours * wagePerHour * 1.5
    }
    
    // Compute daily overtime data.
    private var dailyOvertimeData: [DailyEarnings] {
        var results: [DailyEarnings] = []
        let calendar = Calendar.current
        var current = currentWeekInterval.start
        while current < currentWeekInterval.end {
            let next = calendar.date(byAdding: .day, value: 1, to: current)!
            let dayShifts = weekShifts.filter { $0.startTime >= current && $0.startTime < next }
            let dayOvertime = dayShifts.reduce(0.0) { sum, shift in
                let hours = shift.duration / 3600.0
                return sum + max(0, hours - 8)
            }
            let dayName = DateFormatter().shortWeekdaySymbols[calendar.component(.weekday, from: current) - 1]
            results.append(DailyEarnings(day: dayName, earnings: dayOvertime))
            current = next
        }
        return results
    }
    
    // For “Highest OT Day” tile.
    private var highestOT: DailyEarnings? {
        dailyOvertimeData.max { $0.earnings < $1.earnings }
    }
    
    var body: some View {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let tileWidth = (usableWidth - 14) / 2
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        
                        // Tile 1: Total OT Hours
                        NavigationLink {
                        } label: {
                            mediumTile(title: "OT Hours", icon: "clock.badge.exclamationmark.fill", width: tileWidth)
                                .overlay(
                                    Text(String(format: "%.2fh", totalOvertimeHours))
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                )
                        }
                        
                        // Tile 2: OT Earnings
                        NavigationLink {
                        } label: {
                            smallTile(title: "OT Earnings", icon: "dollarsign.circle.fill", width: tileWidth)
                                .overlay(
                                    Text(formatCurrencyShort(overtimeEarnings))
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                )
                        }
                        
                        // Tile 3: Highest OT Day
                        NavigationLink {
                        } label: {
                            xSmallTile(title: "Max OT Day", width: tileWidth)
                                .overlay(
                                    Text(highestOT != nil ? highestOT!.day : "-")
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                )
                        }
                        
                        // Tile 4: Daily OT Chart
                        NavigationLink {
                        } label: {
                            largeTile(title: "OT Breakdown", icon: "chart.bar.fill", width: tileWidth)
                                .overlay(
                                    Chart(dailyOvertimeData) { item in
                                        BarMark(
                                            x: .value("Day", item.day),
                                            y: .value("OT Hours", item.earnings)
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
            .navigationTitle("Overtime")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // You can preview each view individually:
    NavigationView {
        List {
            NavigationLink("EarningsView") { EarningsView() }
            NavigationLink("LastWeekView") { LastWeekView() }
            NavigationLink("LastMonthView") { LastMonthView() }
            NavigationLink("YTDView") { YTDView() }
            NavigationLink("OvertimeView") { OvertimeView() }
        }
        .navigationTitle("Pay Subviews")
    }
}
