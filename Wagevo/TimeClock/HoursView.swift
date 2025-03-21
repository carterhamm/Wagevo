//
//  HoursView.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/15/25
//

import SwiftUI
import Charts

// (Assuming appleLightGray is defined elsewhere, e.g.)
// let appleLightGray = Color(red: 239/255, green: 239/255, blue: 244/255)

func formatTime(_ hours: Double) -> String {
    let totalMinutes = Int(round(hours * 60))
    let hrs = totalMinutes / 60
    let mins = totalMinutes % 60
    if hrs > 0 && mins > 0 {
        return "\(hrs) hr \(mins) min"
    } else if hrs > 0 {
        return "\(hrs) hr"
    } else {
        return "\(mins) min"
    }
}

// Helper struct to represent hours for a day.
struct DailyHours: Identifiable {
    var id: Date { date }
    let date: Date
    let hours: Double
}

struct HoursView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var dailyHours: [DailyHours] = []      // Past 7 days (for pie chart and metrics)
    @State private var monthlyHours: [DailyHours] = []    // Past 30 days (for line chart)
    @State private var totalHours: String = ""
    @State private var averageShift: String = ""
    @State private var totalShifts: Int = 0
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? appleLightGray : Color.black)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                GeometryReader { geometry in
                    let horizontalPadding = geometry.size.width * 0.04
                    let usableWidth = geometry.size.width - (horizontalPadding * 2)
                    let smallTileWidth = (usableWidth - 14) / 2
                    let largeTileWidth = usableWidth
                    let mediumTileWidth = usableWidth
                    
                    VStack(spacing: 20) {
                        // Top Tile: Pie Chart (past week) with legend, using hoursTile as background.
                        PieChartTile(weeklyHours: dailyHours, width: largeTileWidth)
                            .frame(width: largeTileWidth, height: largeTileWidth)
                        
                        // Medium Tile: Line Chart for hours in the past month (shortened) with y-axis label.
                        hoursLineChart(monthlyHours: monthlyHours, tileWidth: mediumTileWidth)
                        
                        // Two smallTiles side by side for additional metrics.
                        HStack(spacing: 8) {
                            // Small Tile 1: Average Shift
                            ZStack {
                                smallTile(title: "Details", icon: "info.circle.fill", width: smallTileWidth)
                                VStack(alignment: .leading, spacing: 10) {
                                    Spacer()
                                    HStack {
                                        Text("Average Shift:")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(3)
                                    HStack {
                                        Text(averageShift)
                                            .font(.title2)
                                            .fontWeight(.black)
                                            .foregroundColor(Color("AccentColor"))
                                        Spacer()
                                    }
                                }
                                .padding()
                            }
                            .frame(width: smallTileWidth, height: smallTileWidth)
                            
                            // Small Tile 2: Total Hours (now shows all-time)
                            ZStack {
                                smallTile(title: "Total", icon: "hourglass.circle.fill", width: smallTileWidth)
                                VStack(alignment: .leading, spacing: 10) {
                                    Spacer()
                                    HStack {
                                        Text("Total Hours:")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(3)
                                    HStack {
                                        Text(totalHours)
                                            .font(.title2)
                                            .fontWeight(.black)
                                            .foregroundColor(Color("AccentColor"))
                                        Spacer()
                                    }
                                }
                                .padding()
                            }
                            .frame(width: smallTileWidth, height: smallTileWidth)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 10)
                }
                .frame(height: UIScreen.main.bounds.height)
            }
        }
        .navigationTitle("Hours")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }
    
    // Loads data by computing both 7-day and 30-day totals from saved shifts.
    func loadData() {
        // Get saved shifts (assumes Shift has 'startTime' and 'duration')
        let shifts = getPreviousShifts()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Compute 7-day data for pie chart and metrics.
        var sevenDayData: [DailyHours] = []
        for dayOffset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dayShifts = shifts.filter { shift in
                    let shiftDate = calendar.startOfDay(for: shift.startTime)
                    return shiftDate == date
                }
                let totalDuration = dayShifts.reduce(0.0) { $0 + $1.duration }
                let hours = totalDuration / 3600.0
                sevenDayData.append(DailyHours(date: date, hours: hours))
            }
        }
        dailyHours = sevenDayData
        
        // All-time total hours instead of just last 7 days
        let allTimeDuration = shifts.reduce(0.0) { $0 + $1.duration } / 3600.0
        totalHours = formatTime(allTimeDuration)
        
        // Compute monthly data (past 30 days) for the line chart.
        var monthData: [DailyHours] = []
        for dayOffset in (0..<30).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dayShifts = shifts.filter { shift in
                    let shiftDate = calendar.startOfDay(for: shift.startTime)
                    return shiftDate == date
                }
                let totalDuration = dayShifts.reduce(0.0) { $0 + $1.duration }
                let hours = totalDuration / 3600.0
                monthData.append(DailyHours(date: date, hours: hours))
            }
        }
        monthlyHours = monthData
        
        // Additional info: average shift and total shifts in the last 7 days.
        let startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let recentShifts = shifts.filter { $0.startTime >= startDate }
        totalShifts = recentShifts.count
        let totalShiftDuration = recentShifts.reduce(0.0) { $0 + $1.duration }
        let avg = totalShifts > 0 ? totalShiftDuration / Double(totalShifts) / 3600.0 : 0.0
        averageShift = formatTime(avg)
    }
}

// MARK: - PieChartTile: Large tile with a pie chart and legend.
struct PieChartTile: View {
    let weeklyHours: [DailyHours]
    let width: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    // Helper to return the color for a given index.
    func color(for index: Int) -> Color {
        let colors: [Color] = [Color("AccentColor"), Color(.lightGray), Color.blue, Color.orange, Color.purple, Color.green, Color.yellow]
        return colors[index % colors.count]
    }
    
    // Helper: Formats time similar to the shift formatting.
    func formatTime(_ hours: Double) -> String {
        let totalMinutes = Int(round(hours * 60))
        let hrs = totalMinutes / 60
        let mins = totalMinutes % 60
        if hrs > 0 && mins > 0 {
            return "\(hrs) hr \(mins) min"
        } else if hrs > 0 {
            return "\(hrs) hr"
        } else {
            return "\(mins) min"
        }
    }
    
    var body: some View {
        ZStack {
            // Use the reusable tile background.
            hoursTile(title: "Hours", icon: "hourglass.circle.fill", width: width)
            VStack {
                Spacer()
                let filteredData = weeklyHours.filter { $0.hours > 0 }
                HStack {
                    // Increase the pie chart size.
                    PieChartView(data: filteredData)
                        .frame(width: width * 0.5, height: width * 0.5)
                    
                    // Legend: color dot + date on top, percentage underneath
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(filteredData.enumerated()), id: \.element.id) { index, day in
                            let percentage = totalHoursForPie(filteredData) > 0 ? (day.hours / totalHoursForPie(filteredData)) * 100 : 0
                            HStack(alignment: .top, spacing: 10) {
                                Circle()
                                    .fill(color(for: index))
                                    .frame(width: 10, height: 10)
                                    .offset(y: 6)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(formattedDate(day.date))
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text(String(format: "%.1f%%", percentage))
                                        .font(.headline)
                                        .fontWeight(.light)
                                        .foregroundColor(colorScheme == .dark ? .white : .gray)
                                }
                            }
                        }
                    }
                    .padding(.leading, 8)
                    Spacer()
                }
                .padding()
                
                let totalWeek = totalHoursForPie(filteredData)
                
                HStack {
                    Text("Hours This Week")
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray))
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Text(formatTime(totalWeek))
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("AccentColor"))
                    Spacer()
                }
                .padding([.horizontal, .bottom], 20)
                .padding(.top, 1)
            }
        }
    }
    
    func totalHoursForPie(_ data: [DailyHours]) -> Double {
        data.reduce(0) { $0 + $1.hours }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - PieChartView: Draws a simple pie chart using the WeeklyHours data.
struct PieChartView: View {
    let data: [DailyHours]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let total = data.reduce(0) { $0 + $1.hours }
            
            ZStack {
                if total == 0 {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                } else {
                    ForEach(0..<data.count, id: \.self) { index in
                        let startAngle = angle(at: index)
                        let endAngle = angle(at: index + 1)
                        Path { path in
                            path.move(to: center)
                            path.addArc(center: center,
                                        radius: radius,
                                        startAngle: .degrees(startAngle),
                                        endAngle: .degrees(endAngle),
                                        clockwise: false)
                        }
                        .fill(color(for: index))
                    }
                }
            }
        }
    }
    
    func angle(at index: Int) -> Double {
        let total = data.reduce(0) { $0 + $1.hours }
        let angles = data.map { ($0.hours / (total == 0 ? 1 : total)) * 360 }
        let sum = angles.prefix(index).reduce(0, +)
        return sum
    }
    
    func color(for index: Int) -> Color {
        let colors: [Color] = [Color("AccentColor"), Color(.lightGray), Color.blue, Color.orange, Color.purple, Color.green, Color.yellow]
        return colors[index % colors.count]
    }
}

// MARK: - hoursLineChart: Medium tile showing a line graph of past month hours.
private struct hoursLineChart: View {
    let monthlyHours: [DailyHours]
    let tileWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            mediumTile(title: "Past Month", icon: "hourglass.circle.fill", width: tileWidth)
            VStack(spacing: 10) {
                Spacer()
                Chart(monthlyHours) { day in
                    LineMark(
                        x: .value("Date", day.date),
                        y: .value("Hours", day.hours)
                    )
                    .foregroundStyle(Color("AccentColor"))
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month().day())
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                }
                .chartYAxisLabel(position: .top, alignment: .trailing, spacing: 10) {
                    Text("Hours")
                        .foregroundStyle(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray))
                }
                .offset(y: -2) // Moved from -10 to -25 to move "Hours" label further up
                .frame(width: tileWidth * 0.9, height: tileWidth * 0.32)
            }
            .padding()
        }
        .frame(width: tileWidth, height: tileWidth * 0.5)
    }
}

// MARK: - Reused Background Tile
func hoursTile(title: String, icon: String, width: CGFloat) -> some View {
    hoursTileContent(title: title, icon: icon, width: width)
}

fileprivate struct hoursTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            // Tiles are white in light mode and darkGray (from your asset) in dark mode.
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(darkGray) : Color.white)
                .frame(width: width, height: width)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(colorScheme == .dark ? .white : .gray)
                        .padding(.trailing, 5)
                }
                .padding([.top, .horizontal])
                Spacer()
            }
        }
        .frame(maxWidth: width, maxHeight: width)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Pill with SF Symbol
private struct PillWithIconView: View {
    let title: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    private var strokeColor: Color {
        colorScheme == .light ? Color.black.opacity(0.23) : Color.black.opacity(0.42)
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("AccentColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(strokeColor, lineWidth: 3)
                        .blur(radius: 2)
                        .offset(x: 0, y: 0)
                        .mask(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.black, Color.gray, Color.clear]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
        )
    }
}

private func pillWithIcon(title: String, icon: String) -> some View {
    PillWithIconView(title: title, icon: icon)
}

struct HoursView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HoursView()
        }
    }
}
