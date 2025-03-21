//
//  Previous.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/29/25
//

import SwiftUI
import UIKit

// MARK: - A common sort option for both Previous and Upcoming views.
enum ShiftSortOption {
    case none, dateAsc, dateDesc
}

// MARK: - Previous
/// An overlay view (similar to TransactionsGesture) but for previous shifts.
struct Previous: View {
    @Binding var showTransactions: Bool
    var namespace: Namespace.ID

    @State private var sortOption: ShiftSortOption = .none

    // For exporting CSV/PDF and presenting the share sheet
    @State private var shareItems: [Any] = []
    @State private var isShowingShareSheet = false

    // Use dismiss in NavigationStack to pop the view.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            // Calculate horizontal padding and usable width.
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)
            // Define mediumTileWidth as the full usable width.
            let mediumTileWidth = usableWidth
            
            ZStack {
                // Dimmed background, not intercepting taps
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                expandedCard(mediumTileWidth: mediumTileWidth)
                    .cornerRadius(30)
            }
        }
        // Hide the nav bar so top buttons remain tappable
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        // Present share sheet for CSV/PDF
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }

    // MARK: - The expanded card
    fileprivate func expandedCard(mediumTileWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Top capsule handle
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 6)
                .padding(.top, 30)
                .padding(.bottom, 20)
            
            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 0)
                    
                    // The big accent-color header with custom scroll transition
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 450)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            ZStack {
                                // Center swirl image + text
                                ZStack {
                                    Image(systemName: "timer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 175)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .symbolEffect(.wiggle.clockwise.byLayer, options: .nonRepeating)
                                    VStack {
                                        Spacer()
                                        Text("Previous Shifts")
                                            .font(.system(size: 44, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(30)
                                    }
                                }
                                // Top navigation row
                                VStack {
                                    HStack {
                                        // Back arrow (fixed to use dismiss)
                                        Button {
                                            dismiss()      // dismisses the NavigationStack push
                                            showTransactions = false
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(10)
                                        }
                                        Spacer()
                                        // Sort menu
                                        Menu {
                                            Button("Sort by Date (Ascending)") {
                                                sortOption = .dateAsc
                                            }
                                            Button("Sort by Date (Descending)") {
                                                sortOption = .dateDesc
                                            }
                                        } label: {
                                            Image(systemName: "arrow.up.arrow.down")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .frame(width: 36, height: 36)
                                                .background(Color.black.opacity(0.3))
                                                .clipShape(Circle())
                                        }
                                        // Export menu
                                        Menu {
                                            Button("Export CSV") {
                                                let allShifts = getPreviousShiftsForPrevious()
                                                if let csvURL = exportCSV(shifts: allShifts) {
                                                    shareItems = [csvURL]
                                                    isShowingShareSheet = true
                                                }
                                            }
                                            Button("Export PDF") {
                                                let allShifts = getPreviousShiftsForPrevious()
                                                if let pdfURL = exportPDF(shifts: allShifts) {
                                                    shareItems = [pdfURL]
                                                    isShowingShareSheet = true
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .frame(width: 36, height: 36)
                                                .background(Color.black.opacity(0.3))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.horizontal, 28)
                                    .padding(.top, 64)
                                    Spacer()
                                }
                            }
                        )
                        // Overlays
                        .overlay(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.clear, location: 0.0),
                                    .init(color: Color.black.opacity(0.2), location: 1.0)
                                ]),
                                center: UnitPoint(x: 0.5, y: 0.0),
                                startRadius: 195,
                                endRadius: 245
                            )
                            .frame(height: 200)
                            .offset(y: 180)
                            .clipped(),
                            alignment: .bottom
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
                                startPoint: .bottom,
                                endPoint: .center
                            )
                            .frame(height: 125),
                            alignment: .bottom
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.2), Color.clear]),
                                startPoint: .top,
                                endPoint: .center
                            )
                            .ignoresSafeArea()
                            .allowsHitTesting(false),
                            alignment: .top
                        )
                    
                    // Main shifts content
                    PreviousContent(sortOption: sortOption, mediumTileWidth: mediumTileWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 80)
                }
                .frame(maxWidth: .infinity)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { _ in }
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - The main content below the header for Previous Shifts
fileprivate struct PreviousContent: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var shifts: [Shift] = getPreviousShiftsForPrevious()

    let sortOption: ShiftSortOption
    let mediumTileWidth: CGFloat

    var body: some View {
        let sorted = sortShifts(shifts, by: sortOption)

        VStack(spacing: 7) {
            // Top summary tile for Previous Shifts
            ZStack(alignment: .bottom) {
                transactionTile(
                    title: "Previous Shifts",
                    icon: "timer.circle.fill",
                    width: mediumTileWidth
                )
                .background(colorScheme == .dark ? darkGray : .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray),
                                lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 15)
                
                // Summing time for shifts in the last 7 days that have ended.
                let (hours, minutes) = last7DaysTime(shifts: sorted)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Last 7 days")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    HStack {
                        Text("\(hours)h \(minutes)m")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(Color("AccentColor"))
                            .lineLimit(1)
                            .padding(.leading, 16)
                        Spacer()
                    }
                }
                .padding(16)
                .zIndex(1)
            }
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0)
                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                    .blur(radius: phase.isIdentity ? 0 : 10)
            }

            // The shift tiles below.
            if sorted.isEmpty {
                Text("No shifts recorded yet.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(sorted.reversed()) { shift in
                        NavigationLink(destination: ShiftDetailView(shift: shift)) {
                            PreviousShiftTile(shift: shift, width: mediumTileWidth)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteShift(shift: shift)
                            } label: {
                                Label("Delete Shift", systemImage: "trash")
                            }
                        }
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 20)
        .frame(minHeight: UIScreen.main.bounds.height - 500)
        .background(colorScheme == .light ? appleLightGray : .black)
        .onAppear {
            shifts = getPreviousShiftsForPrevious()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShiftUpdated"))) { _ in
            shifts = getPreviousShiftsForPrevious()
        }
    }
}

// MARK: - Shift Tile for Previous Shifts
fileprivate struct PreviousShiftTile: View {
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
                .fill(colorScheme == .dark ? darkGray : .white)

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
                        .foregroundColor(Color("AccentColor"))
                        .padding(.trailing, 12)
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

// MARK: - Helpers for sorting and time calculation

func sortShifts(_ shifts: [Shift], by option: ShiftSortOption) -> [Shift] {
    switch option {
    case .none:
        return shifts
    case .dateAsc:
        return shifts.sorted { $0.startTime < $1.startTime }
    case .dateDesc:
        return shifts.sorted { $0.startTime > $1.startTime }
    }
}

func deleteShift(shift: Shift) {
    var all = getPreviousShiftsForPrevious()
    all.removeAll { $0.shift_id == shift.shift_id }
    if let encoded = try? JSONEncoder().encode(all) {
        UserDefaults.standard.set(encoded, forKey: "savedShifts")
    }
    NotificationCenter.default.post(name: Notification.Name("ShiftUpdated"), object: nil)
}

/// Returns (hours, minutes) total for all shifts in the last 7 days.
/// UPDATED: Only includes shifts from the last 7 days that have ended.
fileprivate func last7DaysTime(shifts: [Shift]) -> (Int, Int) {
    let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    let recent = shifts.filter { $0.startTime >= oneWeekAgo && $0.endTime <= Date() }
    let totalSeconds = recent.reduce(0.0) { $0 + $1.duration }
    let hours = Int(totalSeconds / 3600.0)
    let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
    return (hours, minutes)
}

fileprivate struct transactionTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : .white)
                .frame(width: width, height: width * 0.47)
            VStack {
                HStack {
                    pillWithIcon(title: title, icon: icon)
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: width, maxHeight: width * 0.47)
        .clipped()
    }
}

fileprivate func pillWithIcon(title: String, icon: String) -> some View {
    HStack {
        Image(systemName: icon)
            .foregroundColor(.white)
        Text(title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .background(
        RoundedRectangle(cornerRadius: 15)
            .fill(Color("AccentColor"))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                    .blur(radius: 2)
                    .offset(x: 1, y: 1)
                    .mask(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]),
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                    )
            )
    )
}

// MARK: - Date/Time/Duration Helpers
fileprivate func formattedShiftDate(for date: Date) -> String {
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: Date())
    let shiftYear = calendar.component(.year, from: date)
    let formatter = DateFormatter()
    formatter.dateFormat = shiftYear == currentYear ? "EEE, MMM d" : "EEE, MMM d, yyyy"
    return formatter.string(from: date)
}

fileprivate func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
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

// MARK: - A simple Shift detail view if user taps
struct ShiftDetailView: View {
    let shift: Shift
    var body: some View {
        VStack(spacing: 20) {
            Text("Shift Detail")
                .font(.largeTitle)
                .fontWeight(.heavy)
            Text("Started: \(formattedTime(shift.startTime)) on \(formattedShiftDate(for: shift.startTime))")
            Text("Ended:   \(formattedTime(shift.endTime)) on \(formattedShiftDate(for: shift.endTime))")
            Text("Total Duration: \(formatDuration(shift.duration))")
            Spacer()
        }
        .padding()
    }
}

// MARK: - Private Previous Shifts Getter
// This function wraps the global getPreviousShifts() and filters out upcoming shifts.
private func getPreviousShiftsForPrevious() -> [Shift] {
    return getPreviousShifts().filter { $0.endTime <= Date() }
}

// MARK: - Preview
struct Previous_Previews: PreviewProvider {
    @Namespace static var previewNamespace
    static var previews: some View {
        Previous(showTransactions: .constant(true), namespace: previewNamespace)
    }
}
