//
//  TimeClock.swift
//  Wagevo
//
//  Created by Carter Hammond on [Today’s Date]
//

import SwiftUI

struct TimeClock: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Store previous shifts to trigger immediate updates when a shift is clocked out.
    @State private var previousShifts: [Shift] = getPreviousShifts()
    
    // A single namespace for all matched transitions in this view.
    @Namespace private var timeClockNamespace
    
    @State private var lastShift: Shift? = nil

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)
            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth
            
            let previousShiftsForDisplay = Array(previousShifts.filter { $0.endTime <= Date() }.suffix(3))
            let upcomingShiftsForDisplay = Array(getPreviousShifts()
                .filter { $0.startTime > Date() }
                .sorted { $0.startTime < $1.startTime }
                .prefix(3))
            
            ZStack {
                (colorScheme == .light ? appleLightGray : Color.black)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    // Break the big body into smaller subviews so Swift can handle type-checking
                    VStack(spacing: 13) {
                        
                        // 1) LARGE TILE: "Time Clock"
                        buildTimeClockTile(mediumTileWidth: mediumTileWidth)
                        
                        // 2) PREVIOUS SHIFTS WIDGET
                        buildPreviousShiftsWidget(mediumTileWidth: mediumTileWidth,
                            previousShiftsForDisplay: previousShiftsForDisplay)
                        
                        // 3) "HOURS" + XSmallTiles HStack
                        buildHoursWidget(mediumTileWidth: mediumTileWidth,
                            smallTileWidth: smallTileWidth
                        )
                        
                        // 4) UPCOMING SHIFTS WIDGET
                        buildUpcomingShiftsWidget(mediumTileWidth: mediumTileWidth,
                            upcomingShiftsForDisplay: upcomingShiftsForDisplay)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 10)
                }
                .navigationTitle("Time Clock")
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShiftUpdated"))) { _ in
                previousShifts = getPreviousShifts()
            }
            .onAppear {
                let completedShifts = getPreviousShifts().filter { $0.endTime <= Date() }
                lastShift = completedShifts.sorted(by: { $0.startTime < $1.startTime }).last
            }
        }
    }
    
    // MARK: - Subview 1: Time Clock Tile
    private func buildTimeClockTile(mediumTileWidth: CGFloat) -> some View {
        ZStack {
            NavigationLink {
                DebitCardView()
                    .navigationTransition(.zoom(sourceID: "timeClockTile", in: timeClockNamespace))
            } label: {
                timeClockTile(title: "Time Clock", icon: "clock.fill", width: mediumTileWidth)
                    .matchedTransitionSource(id: "timeClockTile", in: timeClockNamespace)
            }
            VStack {
                Spacer()
                // Removed external offset; the shift is now handled inside LargeInfo.
                LargeInfo(tileWidth: mediumTileWidth)
            }
        }
        .frame(width: mediumTileWidth, height: mediumTileWidth * 0.45 + 16)
    }
    
    // MARK: - Subview 2: Previous Shifts Widget
    private func buildPreviousShiftsWidget(
        mediumTileWidth: CGFloat,
        previousShiftsForDisplay: [Shift]
    ) -> some View {
        NavigationLink {
            Previous(
                showTransactions: .constant(true),
                namespace: timeClockNamespace
            )
            .navigationTransition(.zoom(sourceID: "previousShiftsTile", in: timeClockNamespace))
        } label: {
            ZStack {
                mediumTile(title: "Previous Shifts", icon: "clock.arrow.circlepath", width: mediumTileWidth)
                VStack {
                    ForEach(0..<3, id: \.self) { index in
                        let rowShift: Shift? =
                            index < previousShiftsForDisplay.count
                            ? previousShiftsForDisplay[previousShiftsForDisplay.count - 1 - index]
                            : nil
                        PreviousShiftRow(shift: rowShift, isFirst: index == 0)
                    }
                }
                .padding()
                .padding(.horizontal, 4)
                .padding(.top, 10)
                
                if previousShifts.filter({ $0.endTime <= Date() }).isEmpty {
                    Text("No Previous Shifts")
                        .font(.callout)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .matchedTransitionSource(id: "previousShiftsTile", in: timeClockNamespace)
            .frame(width: mediumTileWidth, height: 180)
        }
    }
    
    // MARK: - Subview 3: Hours + XSmallTiles
    private func buildHoursWidget(
        mediumTileWidth: CGFloat,
        smallTileWidth: CGFloat
    ) -> some View {
        HStack {
            NavigationLink {
                HoursView()
                    .navigationTransition(.zoom(sourceID: "hoursTile", in: timeClockNamespace))
            } label: {
                ZStack {
                    smallTile(title: "Hours", icon: "hourglass.circle.fill", width: smallTileWidth)
                    VStack(spacing: 4) {
                        Spacer()
                        HStack {
                            Text("Last 7 days")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        HStack {
                            Text(formatHoursInLast7Days())
                                .font(.system(size: mediumTileWidth * 0.10, weight: .heavy))
                                .foregroundColor(Color("AccentColor"))
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    .padding([.top, .trailing])
                    .padding(.bottom, 9)
                    .padding(.leading, 16)
                }
                .matchedTransitionSource(id: "hoursTile", in: timeClockNamespace)
            }
            .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
            .contextMenu {
                NavigationLink {
                    DebitCardView()
                        .navigationTransition(.zoom(sourceID: "hoursTileContext", in: timeClockNamespace))
                } label: {
                    Label("View Shift Details", systemImage: "clock")
                        .matchedTransitionSource(id: "hoursTileContext", in: timeClockNamespace)
                }
            }
            
            Spacer()
            
            // ✅ Last Shift Tile
            NavigationLink {
                CalendarView(selectedShift: lastShift)
                    .navigationTransition(.zoom(sourceID: "lastShiftTile", in: timeClockNamespace))
            } label: {
                ZStack {
                    smallTile(title: "Last Shift", icon: "arrow.counterclockwise.circle.fill", width: smallTileWidth)
                    
                    VStack(spacing: 4) {
                        Spacer()
                        HStack {
                            if let shift = lastShift {
                                Text(formatDuration(shift.duration))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 5)
                            } else {
                                Text("--")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 5)
                            }
                            Spacer()
                        }
                        HStack {
                            if let shift = lastShift {
                                let earnings = (shift.duration / 3600.0) * 15.0
                                Text("$\(String(format: "%.2f", earnings))")
                                    .font(.system(size: mediumTileWidth * 0.10, weight: .heavy))
                                    .foregroundColor(Color("AccentColor"))
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            } else {
                                Text("--")
                                    .font(.system(size: mediumTileWidth * 0.10, weight: .heavy))
                                    .foregroundColor(Color("AccentColor"))
                            }
                            Spacer()
                        }
                    }
                    .padding([.top, .trailing])
                    .padding(.bottom, 9)
                    .padding(.leading, 16)
                }
                .clipped()
                .padding(.leading, 0.001)
                .matchedTransitionSource(id: "lastShiftTile", in: timeClockNamespace)
            }
            .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
            .contextMenu {
                NavigationLink {
                    CalendarView(selectedShift: lastShift)
                        .navigationTransition(.zoom(sourceID: "lastShiftTileContext", in: timeClockNamespace))
                } label: {
                    Label("View Shift Details", systemImage: "calendar")
                        .matchedTransitionSource(id: "lastShiftTileContext", in: timeClockNamespace)
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    // MARK: - Subview 4: Upcoming Shifts Widget
    private func buildUpcomingShiftsWidget(
        mediumTileWidth: CGFloat,
        upcomingShiftsForDisplay: [Shift]
    ) -> some View {
        NavigationLink {
            UpcomingShifts(
                showTransactions: .constant(true),
                namespace: timeClockNamespace
            )
            .navigationTransition(.zoom(sourceID: "upcomingShiftsTile", in: timeClockNamespace))
        } label: {
            ZStack {
                mediumTile(title: "Upcoming Shifts", icon: "calendar.badge.clock", width: mediumTileWidth)
                VStack(spacing: 6) {
                    ForEach(Array(upcomingShiftsForDisplay.enumerated()), id: \.offset) { index, shift in
                        UpcomingShiftRow(shift: shift, isFirst: index == 0)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)  // Shift rows now align at the top
                .padding()
                .padding(.horizontal, 4)
                .padding(.top, 10)
                
                if upcomingShiftsForDisplay.isEmpty {
                    VStack {
                        Text("No Upcoming Shifts")
                            .font(.callout)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .matchedTransitionSource(id: "upcomingShiftsTile", in: timeClockNamespace)
            .frame(width: mediumTileWidth, height: 180)
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
        .contextMenu {
            NavigationLink {
                UpcomingShifts(
                    showTransactions: .constant(true),
                    namespace: timeClockNamespace
                )
                .navigationTransition(.zoom(sourceID: "upcomingShiftsTileContext", in: timeClockNamespace))
            } label: {
                Label("View Upcoming Shifts", systemImage: "calendar")
                    .matchedTransitionSource(id: "upcomingShiftsTileContext", in: timeClockNamespace)
            }
        }
    }
    
    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - LargeInfo remains largely unchanged except for the conditional offset
struct LargeInfo: View {
    var tileWidth: CGFloat
    
    private var expandedWidth: CGFloat { tileWidth }
    private var expandedHeight: CGFloat { tileWidth * 0.46 }
    private var collapsedWidth: CGFloat { tileWidth * 0.93 }
    private var collapsedHeight: CGFloat { tileWidth * 0.25 }
    
    @State private var isToggled = false
    @State private var shiftStartTime: Date?
    @State private var shiftDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var borderScale: CGFloat = 0.85
    @State private var currentShift: Shift?
    
    @State private var showError = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Button(action: toggleState) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("AccentColor"), lineWidth: 14)
                        .frame(width: isToggled ? expandedWidth : collapsedWidth,
                               height: isToggled ? expandedHeight : collapsedHeight)
                        .scaleEffect(isToggled ? 1.0 : borderScale, anchor: .center)
                        .animation(.spring(response: 0.5, dampingFraction: 0.4, blendDuration: 0.4),
                                   value: isToggled)
                    
                    if isToggled {
                        Text(formattedElapsedTime())
                            .font(.system(size: 62, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color("AccentColor"))
                    } else {
                        Text("Clock In")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .background(isToggled ? Color(UIColor.systemBackground) : Color("AccentColor"))
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.bottom, isToggled ? 5 : 12)
            }
            .buttonStyle(PlainButtonStyle())
            // Conditionally offset the button: moved up when collapsed, aligned when expanded.
            .offset(y: isToggled ? 0 : -10)
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage ?? "Unknown error"),
                      dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            if let storedTime = UserDefaults.standard.object(forKey: "shiftStartTime") as? TimeInterval {
                let savedDate = Date(timeIntervalSince1970: storedTime)
                shiftStartTime = savedDate
                shiftDuration = Date().timeIntervalSince(savedDate)
                startTimer()
                isToggled = true
                if let data = UserDefaults.standard.data(forKey: "currentShift"),
                   let shift = try? JSONDecoder().decode(Shift.self, from: data) {
                    currentShift = shift
                }
            }
        }
        .onDisappear(perform: invalidateTimer)
    }
    
    private func toggleState() {
        isToggled.toggle()
        if isToggled {
            let now = Date()
            shiftStartTime = now
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "shiftStartTime")
            startTimer()
            
            let newShift = Shift(
                shift_id: generateiOSShiftID(),
                startTime: now,
                endTime: now,
                duration: 0,
                user_id: "dummy-user-id"
            )
            currentShift = newShift
            if let data = try? JSONEncoder().encode(newShift) {
                UserDefaults.standard.set(data, forKey: "currentShift")
            }
            strongElongatedHaptic()
        } else {
            let now = Date()
            let rawDuration = now.timeIntervalSince(shiftStartTime ?? now)
            if var current = currentShift {
                current = Shift(
                    shift_id: current.shift_id,
                    startTime: current.startTime,
                    endTime: now,
                    duration: rawDuration,
                    user_id: current.user_id
                )
                saveShift(current)
                currentShift = nil
                UserDefaults.standard.removeObject(forKey: "currentShift")
            }
            quickDoubleHaptic()
            stopAndResetTimer()
            UserDefaults.standard.removeObject(forKey: "shiftStartTime")
            NotificationCenter.default.post(name: Notification.Name("ShiftUpdated"), object: nil)
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2)) {
            borderScale = isToggled ? 1.0 : 0.85
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            shiftDuration += 1
        }
    }
    
    private func stopAndResetTimer() {
        timer?.invalidate()
        timer = nil
        shiftDuration = 0
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
    }
    
    private func formattedElapsedTime() -> String {
        let hours = Int(shiftDuration) / 3600
        let minutes = (Int(shiftDuration) % 3600) / 60
        let seconds = Int(shiftDuration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func strongElongatedHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred(intensity: 1.0)
    }
    
    private func quickDoubleHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            generator.impactOccurred()
        }
    }
}

// MARK: - Rows remain unchanged
fileprivate struct PreviousShiftRow: View {
    @Environment(\.colorScheme) var colorScheme
    let shift: Shift?
    let isFirst: Bool
    
    var body: some View {
        HStack {
            if let shift = shift {
                Text(shiftFormattedDate(shift.startTime))
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Text(formatDuration(shift.duration))
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            } else {
                Text("")
                Spacer()
            }
        }
        .padding(
            isFirst
            ? EdgeInsets(top: 35, leading: 0, bottom: 5, trailing: 0)
            : EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
        )
    }
}

fileprivate struct UpcomingShiftRow: View {
    @Environment(\.colorScheme) var colorScheme
    let shift: Shift
    let isFirst: Bool

    var body: some View {
        HStack {
            Text(shiftFormattedDate(shift.startTime))
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
            Text(shift.duration > 0 ? formatDuration(shift.duration) : "")
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .padding(
            isFirst
            ? EdgeInsets(top: 35, leading: 0, bottom: 5, trailing: 0)
            : EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
        )
    }
}

// MARK: - Date/Time Helpers remain as is
fileprivate func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: date)
}

fileprivate func shiftFormattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d" // e.g., February 4
    return formatter.string(from: date)
}

fileprivate func formatDuration(_ duration: TimeInterval) -> String {
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

struct TimeClock_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimeClock()
        }
    }
}
