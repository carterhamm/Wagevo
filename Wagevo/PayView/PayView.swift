//
//  PayView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/29/25.
//

import SwiftUI
import Foundation
import Charts  // Requires iOS 16+

// MARK: - Earnings Data Model
struct EarningsData: Identifiable {
    let id = UUID()
    let month: String
    let earnings: Double
}

// MARK: - YTD Earnings Line Chart View
struct YtdEarningsLineChart: View {
    let data: [EarningsData]
    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Month", item.month),
                y: .value("Earnings", item.earnings)
            )
            PointMark(
                x: .value("Month", item.month),
                y: .value("Earnings", item.earnings)
            )
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

// MARK: - Currency Formatting Helper
func formatCurrencyShort(_ value: Double) -> String {
    if value >= 1000 {
        let divided = value / 1000
        return "$\(String(format: "%.2f", divided))K"
    } else {
        return "$\(String(format: "%.2f", value))"
    }
}

// MARK: - Subviews for Tiles

// Top Tile: This Week Earnings
struct TopTileView: View {
    let width: CGFloat
    let weeklyEarnings: Double
    let namespace: Namespace.ID
    
    var body: some View {
        NavigationLink {
            EarningsView()
                .navigationTransition(.zoom(sourceID: "topTile", in: namespace))
        } label: {
            ZStack {
                mediumTile(title: "Earnings", icon: "dollarsign.circle.fill", width: width)
                VStack {
                    Spacer()
                    HStack {
                        Text("This Week")
                            .font(.system(size: width * 0.05, weight: .semibold))
                            .foregroundColor(colorSchemeDependentForeground())
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                            .padding(.leading, 1.0)
                        Spacer()
                    }
                    HStack {
                        Text("$\(String(format: "%.2f", weeklyEarnings))")
                            .font(.system(size: width * 0.18, weight: .heavy))
                            .foregroundColor(Color("AccentColor"))
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        Spacer()
                    }
                }
                .padding(.top)
                .padding(.leading)
                .padding(.bottom, 7)
            }
        }
        .buttonStyle(BouncyButtonStyle())
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
        .contextMenu {
            NavigationLink {
                EarningsView()
                    .navigationTransition(.zoom(sourceID: "topTileContext", in: namespace))
            } label: {
                Label("View Earnings", systemImage: "dollarsign.circle")
                    .matchedTransitionSource(id: "topTileContext", in: namespace)
            }
        }
    }
    
    // Local helper for foreground color based on color scheme.
    private func colorSchemeDependentForeground() -> Color {
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .light ? .black : .white
        })
    }
    
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
}

// YTD Earnings Tile (to be placed where the Previous Paychecks tile was)
struct YTDEarningsTileView: View {
    let width: CGFloat
    let data: [EarningsData]
    let namespace: Namespace.ID
    
    var body: some View {
        NavigationLink {
            YTDView()
                .navigationTransition(.zoom(sourceID: "ytdTile", in: namespace))
        } label: {
            ZStack {
                VStack {
                    mediumTile(title: "YTD Earnings", icon: "chart.line.uptrend.xyaxis", width: width)
                }
                VStack {
                    YtdEarningsLineChart(data: data)
                        .frame(width: 350, height: 100)
                        .padding(.horizontal, 12)
                        .padding(.top, 55)
                }
            }
            .frame(width: width, height: 185)
        }
        .buttonStyle(BouncyButtonStyle())
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
        .contextMenu {
            NavigationLink {
                YTDView()
                    .navigationTransition(.zoom(sourceID: "ytdTileContext", in: namespace))
            } label: {
                Label("View YTD Earnings", systemImage: "chart.line.uptrend.xyaxis")
                    .matchedTransitionSource(id: "ytdTileContext", in: namespace)
            }
        }
    }
    
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
}

// Last Week Earnings xSmallTile
struct LastWeekTileView: View {
    let width: CGFloat
    let earnings: Double
    let namespace: Namespace.ID
    
    var body: some View {
        NavigationLink {
            LastWeekView()
                .navigationTransition(.zoom(sourceID: "lastWeekTile", in: namespace))
        } label: {
            ZStack {
                VStack {
                    xSmallTile(title: "Last Week", width: width)
                }
                VStack {
                    Spacer()
                    HStack {
                        Text(formatCurrencyShort(earnings))
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
                        Text("Last 7d")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 3.0)
                            .padding()
                            .padding(.trailing, 5.0)
                    }
                }
            }
            .clipped()
            .padding(.leading, 0.001)
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
        .matchedTransitionSource(id: "lastWeekTile", in: namespace)
    }
    
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
}

// Last Month Earnings xSmallTile
struct LastMonthTileView: View {
    let width: CGFloat
    let earnings: Double
    let namespace: Namespace.ID
    
    var body: some View {
        NavigationLink {
            LastMonthView()
                .navigationTransition(.zoom(sourceID: "lastMonthTile", in: namespace))
        } label: {
            ZStack {
                VStack {
                    xSmallTile(title: "Last Month", width: width)
                }
                VStack {
                    Spacer()
                    HStack {
                        Text(formatCurrencyShort(earnings))
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
            .padding(.leading, 0.001)
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
        .matchedTransitionSource(id: "lastMonthTile", in: namespace)
    }
    
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
}

// Overtime Tile (Bottom)
struct OvertimeTileView: View {
    let width: CGFloat
    let namespace: Namespace.ID
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink {
            OvertimeView()
                .navigationTransition(.zoom(sourceID: "overtimeTile", in: namespace))
        } label: {
            ZStack {
                VStack {
                    mediumTile(title: "Overtime", icon: "clock.badge.exclamationmark.fill", width: width)
                }
                Text("No Overtime Reported")
                    .font(.headline)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding()
            }
            .frame(width: width, height: 185)
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
        .contextMenu {
            NavigationLink {
                OvertimeView()
                    .navigationTransition(.zoom(sourceID: "overtimeTileContext", in: namespace))
            } label: {
                Label("View Overtime", systemImage: "clock")
                    .matchedTransitionSource(id: "overtimeTileContext", in: namespace)
            }
        }
    }
    
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
}

struct PayView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var lastShift: Shift? = nil
    
    // A namespace for the matched transitions.
    @Namespace private var payViewNamespace
    
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
                        
                        // Top Tile: This Week Earnings
                        TopTileView(width: mediumTileWidth, weeklyEarnings: computeWeeklyEarnings(), namespace: payViewNamespace)
                        
                        // YTD Earnings Tile (replacing Previous Paychecks)
                        YTDEarningsTileView(width: mediumTileWidth, data: computeYtdEarningsData(), namespace: payViewNamespace)
                        
                        // Small and Extra Small Tiles
                        HStack {
                            // Withheld Tile (unchanged)
                            NavigationLink {
                                WithholdingsView()
                                    .navigationTransition(.zoom(sourceID: "lastShiftTile", in: payViewNamespace))
                            } label: {
                                ZStack {
                                    smallTile(title: "Withheld", icon: "centsign.ring.dashed", width: smallTileWidth)
                                    VStack(spacing: 4) {
                                        Spacer()
                                        HStack {
                                            Text("14%")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 5)
                                            Spacer()
                                        }
                                        HStack {
                                            let withheld = computeWeeklyEarnings() * 0.14
                                            Text("$\(String(format: "%.2f", withheld))")
                                                .font(.system(size: mediumTileWidth * 0.12, weight: .heavy))
                                                .foregroundColor(Color("AccentColor"))
                                                .minimumScaleFactor(0.8)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                }
                                .clipped()
                                .matchedTransitionSource(id: "lastShiftTile", in: payViewNamespace)
                            }
                            .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                            .contextMenu {
                                NavigationLink {
                                    WithholdingsView()
                                        .navigationTransition(.zoom(sourceID: "lastShiftTileContext", in: payViewNamespace))
                                } label: {
                                    Label("View Withholdings", systemImage: "calendar")
                                        .matchedTransitionSource(id: "lastShiftTileContext", in: payViewNamespace)
                                }
                            }
                            
                            Spacer()
                            
                            // xSmallTiles for Last Week and Last Month
                            VStack(spacing: 12) {
                                LastWeekTileView(width: smallTileWidth, earnings: computeLastWeekEarnings(), namespace: payViewNamespace)
                                LastMonthTileView(width: smallTileWidth, earnings: computeLastMonthEarnings(), namespace: payViewNamespace)
                            }
                        }
                        .padding(.vertical, 5)
                        
                        // Bottom Tile: Overtime
                        OvertimeTileView(width: mediumTileWidth, namespace: payViewNamespace)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 7)
                }
                .navigationTitle("Pay")
            }
        }
        .onAppear {
            let completedShifts = getPreviousShifts().filter { $0.endTime <= Date() }
            lastShift = completedShifts.sorted(by: { $0.startTime < $1.startTime }).last
        }
    }
    
    // MARK: - Compute Weekly Earnings Helper
    private func computeWeeklyEarnings() -> Double {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let weeklyShifts = getPreviousShifts().filter { shift in
            return shift.startTime >= sevenDaysAgo && shift.startTime <= Date()
        }
        let totalDuration = weeklyShifts.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalDuration / 3600.0
        return totalHours * 15.0
    }
    
    // Helper to compute last week's earnings (last 7 days)
    private func computeLastWeekEarnings() -> Double {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let shifts = getPreviousShifts().filter { $0.startTime >= sevenDaysAgo && $0.startTime <= Date() }
        let totalDuration = shifts.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalDuration / 3600.0
        return totalHours * 15.0
    }
    
    // Helper to compute last month's earnings (last 30 days)
    private func computeLastMonthEarnings() -> Double {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        let shifts = getPreviousShifts().filter { $0.startTime >= thirtyDaysAgo && $0.startTime <= Date() }
        let totalDuration = shifts.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalDuration / 3600.0
        return totalHours * 15.0
    }
    
    // Helper to compute YTD earnings data for the line chart
    private func computeYtdEarningsData() -> [EarningsData] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
        let shifts = getPreviousShifts().filter { $0.startTime >= startOfYear && $0.startTime <= Date() }
        var earningsByMonth: [Int: Double] = [:]
        for shift in shifts {
            let month = calendar.component(.month, from: shift.startTime)
            let earnings = (shift.duration / 3600.0) * 15.0
            earningsByMonth[month, default: 0.0] += earnings
        }
        let currentMonth = calendar.component(.month, from: Date())
        var data: [EarningsData] = []
        let formatter = DateFormatter()
        let monthSymbols = formatter.shortMonthSymbols ?? []
        for month in 1...currentMonth {
            let earnings = earningsByMonth[month] ?? 0.0
            let monthName = monthSymbols[month - 1]
            data.append(EarningsData(month: monthName, earnings: earnings))
        }
        return data
    }
    
    // Withholdings View (unchanged)
    struct WithholdingsView: View {
        @Environment(\.colorScheme) var colorScheme
        
        let totalMade: Double = 1000.0
        let withheldPercentage: Double = 14.0
        var totalWithheld: Double { totalMade * withheldPercentage / 100.0 }
        var netAmount: Double { totalMade - totalWithheld }
        
        var body: some View {
            VStack(spacing: 13) {
                let withheld = withheldPercentage
                let remainder = 100.0 - withheldPercentage
                let remainderColor: Color = colorScheme == .dark ? .white : .black
                PieChartView(data: [withheld, remainder], colors: [Color.purple, remainderColor])
                    .frame(width: 250, height: 250)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Made:")
                        Spacer()
                        Text("$\(String(format: "%.2f", totalMade))")
                    }
                    HStack {
                        Text("Total Withheld:")
                        Spacer()
                        Text("$\(String(format: "%.2f", totalWithheld))")
                    }
                    HStack {
                        Text("Net Amount:")
                        Spacer()
                        Text("$\(String(format: "%.2f", netAmount))")
                    }
                }
                .padding(.horizontal, 40)
                .font(.title2)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Withholdings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Pie Chart View (unchanged)
    struct PieChartView: View {
        var data: [Double]
        var colors: [Color]
        
        var total: Double {
            data.reduce(0, +)
        }
        
        var angles: [Angle] {
            var currentAngle = Angle(degrees: 0)
            var result: [Angle] = []
            for value in data {
                let percentage = value / total
                let angle = Angle(degrees: percentage * 360)
                result.append(currentAngle)
                currentAngle += angle
            }
            return result
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<data.count, id: \.self) { index in
                        let startAngle = angles[index]
                        let endAngle = index == data.count - 1 ? Angle(degrees: 360) : angles[index + 1]
                        PieSlice(startAngle: startAngle, endAngle: endAngle)
                            .fill(colors[index])
                    }
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
    }

    struct PieSlice: Shape {
        var startAngle: Angle
        var endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            var path = Path()
            path.move(to: center)
            path.addArc(center: center,
                        radius: radius,
                        startAngle: startAngle - Angle(degrees: 90),
                        endAngle: endAngle - Angle(degrees: 90),
                        clockwise: false)
            path.closeSubpath()
            return path
        }
    }
    
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
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
    NavigationStack {
        PayView()
    }
}
