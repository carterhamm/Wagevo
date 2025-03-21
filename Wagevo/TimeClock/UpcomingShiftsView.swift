//
//  UpcomingShiftsView.swift
//  Wagevo
//
//  Created by Carter Hammond on [Today’s Date]
//

import SwiftUI
import Foundation

// A helper that returns upcoming shifts (assuming getPreviousShifts() exists)
func getUpcomingShifts() -> [Shift] {
    return getPreviousShifts().filter { $0.startTime > Date() }
}

// Helper to compute the countdown text for a shift
fileprivate func countdownText(for shift: Shift) -> String {
    let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: shift.startTime).day ?? 0
    if daysUntil < 0 {
        return "Past"
    } else if daysUntil == 0 {
        return "Today"
    } else if daysUntil == 1 {
        return "Tomorrow"
    } else {
        return "in \(daysUntil) days"
    }
}

struct UpcomingShifts: View {
    @Binding var showTransactions: Bool
    var namespace: Namespace.ID

    @State private var sortOption: ShiftSortOption = .dateAsc

    // For exporting CSV/PDF and presenting the share sheet
    @State private var shareItems: [Any] = []
    @State private var isShowingShareSheet = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)
            let mediumTileWidth = usableWidth

            ZStack {
                // Dimmed background
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                expandedCard(mediumTileWidth: mediumTileWidth)
                    .cornerRadius(30)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }

    // MARK: - The expanded card for Upcoming Shifts
    func expandedCard(mediumTileWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Top capsule handle
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 6)
                .padding(.top, 30)
                .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 0)

                    // The big accent-color header
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 450)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            ZStack {
                                // Center swirl image + header text
                                ZStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 175)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                    VStack {
                                        Spacer()
                                        Text("Upcoming Shifts")
                                            .font(.system(size: 44, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(30)
                                    }
                                }
                                // Top navigation row
                                VStack {
                                    HStack {
                                        Button {
                                            dismiss()
                                            showTransactions = false
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(10)
                                        }
                                        Spacer()
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
                                        Menu {
                                            Button("Export CSV") {
                                                let allShifts = getUpcomingShifts()
                                                if let csvURL = exportCSV(shifts: allShifts) {
                                                    shareItems = [csvURL]
                                                    isShowingShareSheet = true
                                                }
                                            }
                                            Button("Export PDF") {
                                                let allShifts = getUpcomingShifts()
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

                    // Main shifts content for Upcoming Shifts
                    UpcomingContent(sortOption: sortOption, mediumTileWidth: mediumTileWidth)
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

// MARK: - The main content below the header for Upcoming Shifts
fileprivate struct UpcomingContent: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var shifts: [Shift] = getUpcomingShifts()

    let sortOption: ShiftSortOption
    let mediumTileWidth: CGFloat

    var body: some View {
        let sorted = sortShifts(shifts, by: sortOption)
        VStack(spacing: 7) {
            // Top summary tile for Upcoming Shifts
            ZStack(alignment: .bottom) {
                transactionTile(
                    title: "Upcoming Shifts",
                    icon: "calendar.circle.fill",
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
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Upcoming Shifts")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    HStack {
                        Text("\(shifts.count) shift\(shifts.count == 1 ? "" : "s") scheduled")
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

            if sorted.isEmpty {
                Text("No upcoming shifts scheduled.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(sorted) { shift in
                        NavigationLink(destination: ShiftDetailView(shift: shift)) {
                            UpcomingShiftTile(shift: shift, width: mediumTileWidth)
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
            shifts = getUpcomingShifts()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShiftUpdated"))) { _ in
            shifts = getUpcomingShifts()
        }
    }
}

// MARK: - Shift Tile for Upcoming Shifts
fileprivate struct UpcomingShiftTile: View {
    let shift: Shift
    let width: CGFloat
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let dateString = formattedShiftDate(for: shift.startTime)
        let durationText = formatDuration(shift.duration)
        let timeRangeText = "(\(formattedTime(shift.startTime)) - \(formattedTime(shift.endTime)))"
        let countdown = countdownText(for: shift)

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
                    Text(countdown)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("AccentColor"))
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

// MARK: - Preview
struct UpcomingShiftsView_Previews: PreviewProvider {
    @Namespace static var previewNamespace
    static var previews: some View {
        UpcomingShifts(showTransactions: .constant(true), namespace: previewNamespace)
    }
}
