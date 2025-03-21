//
//  CalendarViewV1.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/28/25
//

import SwiftUI

struct CalendarViewV1: View {
    // Pass a selectedDate from TimeClock or from somewhere else.
    init(selectedDate: Date = Date()) {
        self._selectedDate = State(initialValue: selectedDate)
    }
    
    @State private var selectedDate: Date
    @State private var shiftsForSelectedDate: [Shift] = []
    
    // Added environment colorScheme for background selection.
    @Environment(\.colorScheme) var colorScheme
    
    // **NEW**: We need a namespace to call `Previous(...)`.
    @Namespace private var calendarNamespace
    
    var body: some View {
        NavigationStack {
            // Set overall background: appleLightGray in light mode; black in dark.
            ScrollView {
                VStack(spacing: 20) {
                    // Graphical Calendar
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .frame(height: 350)
                            .clipped()
                    }
                    .padding()
                    
                    Divider()
                    
                    // SHIFT DETAILS using custom CalendarShiftTile
                    VStack {
                        HStack {
                            Spacer()
                            Text("Shift Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Text(formattedDate(selectedDate))
                                .font(.title3)
                                .foregroundColor(.accentColor)
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        if shiftsForSelectedDate.isEmpty {
                            Text("No shifts for this day.")
                                .font(.body)
                                .foregroundColor(.gray)
                        } else {
                            // **UPDATED**: We must call `Previous(showTransactions:, namespace:)`
                            ForEach(shiftsForSelectedDate) { shift in
                                NavigationLink(
                                    destination: Previous(
                                        showTransactions: .constant(true),
                                        namespace: calendarNamespace
                                    )
                                ) {
                                    CalendarShiftTile(shift: shift, width: UIScreen.main.bounds.width * 0.9)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .background(colorScheme == .light ? appleLightGray : Color.black)
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedDate) { newDate, _ in
                loadShiftsForSelectedDate()
            }
            .onAppear {
                loadShiftsForSelectedDate()
            }
        }
    }
    
    // Filter all shifts to those on the selected day.
    private func loadShiftsForSelectedDate() {
        let allShifts = getPreviousShifts()  // This must return [Shift]
        let cal = Calendar.current
        shiftsForSelectedDate = allShifts.filter { shift in
            cal.isDate(shift.startTime, inSameDayAs: selectedDate)
        }
    }
}

// Helper: Formats a date for a shift tile (e.g., "EEE, MMM d" or "EEE, MMM d, yyyy")
private func formattedShiftDate(for date: Date) -> String {
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: Date())
    let shiftYear = calendar.component(.year, from: date)
    let formatter = DateFormatter()
    formatter.dateFormat = shiftYear == currentYear ? "EEE, MMM d" : "EEE, MMM d, yyyy"
    return formatter.string(from: date)
}

// Helper: Formats a time value (e.g., "10:00 AM")
private func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: date)
}

// Helper: Formats a duration as "4h 6m", omitting hours or minutes if 0.
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

// MARK: - CalendarShiftTile
struct CalendarShiftTile: View {
    let shift: Shift
    let width: CGFloat
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let dateString = formattedShiftDate(for: shift.startTime)
        let timeRange = "(\(formattedTime(shift.startTime)) - \(formattedTime(shift.endTime ?? shift.startTime)))"
        
        let leftGroup = VStack(alignment: .leading, spacing: 4) {
            Text(dateString)
                .font(.headline)
                .foregroundColor(Color("AccentColor"))
                .padding(.top, 15)
                .padding(.leading, 8)
            Spacer()
            Text(timeRange)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 15)
                .padding(.leading, 8)
        }
        
        let durationText = formatDuration(shift.duration)
        let rightGroup = VStack {
            Spacer()
            Text(durationText)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
        }
        .padding(.vertical)
        .padding(.trailing, 8)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(darkGray) : Color.white)
            HStack {
                leftGroup
                Spacer()
                rightGroup
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
        }
        .frame(width: width, height: 80)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.vertical, 4)
    }
}

// MARK: - CalendarView
struct CalendarView: View {
    var selectedShift: Shift?
    
    var body: some View {
        CalendarViewV1(selectedDate: selectedShift?.startTime ?? Date())
            .navigationTitle("Calendar")
    }
}

struct CalendarViewV1_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewV1()
    }
}
