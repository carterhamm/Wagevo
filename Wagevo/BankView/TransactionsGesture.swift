//
//  TransactionsGesture.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/29/25
//

import SwiftUI
import UIKit

// MARK: - ScrollView Offset Tracking
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - TransactionsGesture
struct TransactionsGesture: View {
    // Binding to close the view.
    @Binding var showTransactions: Bool
    // Shared namespace for matched geometry effects.
    var namespace: Namespace.ID

    // Track the sort option.
    @State private var sortOption: SortOption = .none

    // For CSV/PDF export & share sheet.
    @State private var shareItems: [Any] = []
    @State private var isShowingShareSheet = false

    // State variables for search functionality.
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            // Use 4% horizontal padding.
            let horizontalPadding = geometry.size.width * 0.04
            let usableWidth = geometry.size.width - (horizontalPadding * 2)
            // mediumTileWidth is defined as the full usable width.
            let mediumTileWidth = usableWidth

            ZStack {
                // Dimmed background.
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

    // MARK: - Expanded Card
    func expandedCard(mediumTileWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Drag-handle pill.
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 6)
                .padding(.top, 30)
                .padding(.bottom, 20)

            // Scrollable content including header and transactions list.
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hidden GeometryReader for offset tracking.
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollViewOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 0)

                    // Header with accent color.
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 450)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            ZStack {
                                // Center swirl image + header text.
                                ZStack {
                                    Image(systemName: "arrow.left.arrow.right")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 175)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                    VStack {
                                        Spacer()
                                        Text("Transactions")
                                            .font(.system(size: 44, weight: .bold))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(30)
                                    }
                                }
                                // Top navigation row.
                                VStack {
                                    if showSearch {
                                        HStack(spacing: 8) {
                                            ZStack(alignment: .leading) {
                                                if searchText.isEmpty {
                                                    Text("Search transactions")
                                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                                        .padding(.leading, 36)
                                                }
                                                HStack {
                                                    Image(systemName: "magnifyingglass")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                                        .padding(.leading, 8)
                                                    TextField("", text: $searchText, onCommit: {
                                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                    })
                                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                                    .submitLabel(.search)
                                                }
                                            }
                                            .frame(height: 36)
                                            .padding(.horizontal, 12)
                                            .background(colorScheme == .light ? Color.white : Color(UIColor.darkGray))
                                            .cornerRadius(35)
                                            .transition(.move(edge: .trailing))
                                            
                                            // Cancel button.
                                            Button {
                                                withAnimation {
                                                    showSearch = false
                                                    searchText = ""
                                                }
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            } label: {
                                                Image(systemName: "chevron.left")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                            }
                                        }
                                        .padding(.horizontal, 28)
                                        .padding(.top, 64)
                                        .transition(.move(edge: .leading))
                                    } else {
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
                                            HStack(spacing: 12) {
                                                Button {
                                                    withAnimation {
                                                        showSearch = true
                                                    }
                                                } label: {
                                                    Image(systemName: "magnifyingglass")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .frame(width: 36, height: 36)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
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
                                                        let allShifts = getPreviousShifts()
                                                        if let csvURL = exportCSV(shifts: allShifts) {
                                                            shareItems = [csvURL]
                                                            isShowingShareSheet = true
                                                        }
                                                    }
                                                    Button("Export PDF") {
                                                        let allShifts = getPreviousShifts()
                                                        if let pdfURL = exportPDF(shifts: allShifts) {
                                                            shareItems = [pdfURL]
                                                            isShowingShareSheet = true
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .frame(width: 36, height: 36)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 28)
                                        .padding(.top, 64)
                                    }
                                    Spacer()
                                }
                            }
                        )
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

                    // Core transactions content.
                    TransactionsContent(sortOption: sortOption, searchText: searchText, mediumTileWidth: mediumTileWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 80)
                }
                .frame(maxWidth: .infinity)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { _ in }
            .ignoresSafeArea(.container, edges: [.top, .leading, .trailing])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Sorting Options
    enum SortOption {
        case none
        case dateAsc
        case dateDesc
    }
}

// MARK: - TransactionsContent (Summary Tile Updated)
struct TransactionsContent: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var transactions: [Shift] = getPreviousShifts()

    let sortOption: TransactionsGesture.SortOption
    let searchText: String
    let mediumTileWidth: CGFloat

    var body: some View {
        let sortedTransactions = sortShifts(transactions, by: sortOption)
        let filteredTransactions = sortedTransactions.filter { shift in
            if searchText.isEmpty { return true }
            let combined = "\(formattedShiftDate(for: shift.startTime)) \(formattedTime(shift.startTime)) \(formattedTime(shift.endTime)) \(formatDuration(shift.duration))"
            return combined.lowercased().contains(searchText.lowercased())
        }

        VStack(spacing: 7) {
            // Updated summary tile.
            ZStack(alignment: .bottom) {
                transactionTile(
                    title: "Transactions",
                    icon: "arrow.left.arrow.right.circle.fill",
                    width: mediumTileWidth
                )
                .background(colorScheme == .dark ? darkGray : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.lightGray),
                                lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 15)
                
                // Calculate metrics.
                let totalEarned = filteredTransactions.reduce(0.0) { partialResult, shift in
                    let amount = (shift.duration / 3600.0) * 15.0
                    return partialResult + max(amount, 0)
                }
                let totalSpending = filteredTransactions.reduce(0.0) { partialResult, shift in
                    let amount = (shift.duration / 3600.0) * 15.0
                    return partialResult + (amount < 0 ? abs(amount) : 0)
                }
                let spendingString = formatWithCommas(totalSpending)
                let earnedString = formatWithCommas(totalEarned)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Spending: $\(spendingString)")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    HStack {
                        Text("Earnings: $\(earnedString)")
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
            
            if filteredTransactions.isEmpty {
                Text("No transactions recorded yet.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredTransactions.reversed()) { shift in
                        NavigationLink(destination: TransactionDetailView(shift: shift)
                        ){
                            TransactionsShiftTile(shift: shift, width: mediumTileWidth)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteTransaction(shift: shift)
                            } label: {
                                Label("Delete Transaction", systemImage: "trash")
                            }
                        }
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.3)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 5)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 20)
        .frame(minHeight: UIScreen.main.bounds.height - 500)
        .background(colorScheme == .light ? appleLightGray : Color.black)
        .onAppear {
            transactions = getPreviousShifts()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShiftUpdated"))) { _ in
            transactions = getPreviousShifts()
        }
    }
}

// MARK: - SHIFT TILE with "PreviousShiftsView" formatting
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
                NavigationLink(destination: CashOutView()) {
                    Group {
                        if shift.isPaid {
                            VStack {
                                Spacer()
                                Text("$\(String(format: "%.2f", earnings))")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.accentColor)
                                    .padding(.trailing, 8)
                                Spacer()
                            }
                            .padding(.vertical)
                            .padding(.trailing, 8)
                        } else {
                            VStack {
                                Spacer()
                                Text("$\(String(format: "%.2f", earnings))")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(Color.accentColor)
                                            .frame(height: 44)
                                            .padding(.horizontal, -10)
                                            .offset(x: -5)
                                    )
                                    .padding(.trailing, 16)
                                Spacer()
                            }
                            .padding(.vertical)
                            .padding(.trailing, 16)
                        }
                    }
                    
                }
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

// MARK: - Summaries Tile
func transactionTile(title: String, icon: String, width: CGFloat) -> some View {
    return transactionTileContent(title: title, icon: icon, width: width)
}

fileprivate struct transactionTileContent: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? darkGray : Color.white)
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

struct TransactionDetailView: View {
    let shift: Shift
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Transaction Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date: \(formattedShiftDate(for: shift.startTime))")
                    Text("Time: \(formattedTime(shift.startTime)) - \(formattedTime(shift.endTime))")
                    Text("Duration: \(formatDuration(shift.duration))")
                    let earnings = (shift.duration / 3600.0) * 15.0
                    Text("Amount Earned: $\(String(format: "%.2f", earnings))")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Pill with Icon
private func pillWithIcon(title: String, icon: String) -> some View {
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

// MARK: - Helper to format money with thousands separators
private func formatWithCommas(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "0.00"
}

// MARK: - Sorting Helper
private func sortShifts(_ shifts: [Shift], by option: TransactionsGesture.SortOption) -> [Shift] {
    switch option {
    case .none:
        return shifts
    case .dateAsc:
        return shifts.sorted { $0.startTime < $1.startTime }
    case .dateDesc:
        return shifts.sorted { $0.startTime > $1.startTime }
    }
}

// MARK: - Deletion Helper
private func deleteTransaction(shift: Shift) {
    var shifts = getPreviousShifts()
    shifts.removeAll { $0.shift_id == shift.shift_id }
    if let encoded = try? JSONEncoder().encode(shifts) {
        UserDefaults.standard.set(encoded, forKey: "savedShifts")
    }
    NotificationCenter.default.post(name: Notification.Name("ShiftUpdated"), object: nil)
}

// MARK: - Date/Time Helpers
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

// MARK: - ShareSheet for CSV/PDF
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - CSV/PDF Export
func exportCSV(shifts: [Shift]) -> URL? {
    var csvText = "Date,Start,End,Duration (s),Hours,Earnings\n"
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm"
    for s in shifts {
        let dateStr = formattedShiftDate(for: s.startTime)
        let startStr = df.string(from: s.startTime)
        let endStr = df.string(from: s.endTime)
        let hours = s.duration / 3600.0
        let earnings = hours * 15.0
        csvText += "\(dateStr),\(startStr),\(endStr),\(Int(s.duration)),\(hours),\(earnings)\n"
    }
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Transactions.csv")
    do {
        try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    } catch {
        print("Error writing CSV: \(error)")
        return nil
    }
}

func exportPDF(shifts: [Shift]) -> URL? {
    let pdfURL = FileManager.default.temporaryDirectory.appendingPathComponent("Transactions.pdf")
    UIGraphicsBeginPDFContextToFile(pdfURL.path, CGRect.zero, nil)
    UIGraphicsBeginPDFPage()
    guard let context = UIGraphicsGetCurrentContext() else {
        UIGraphicsEndPDFContext()
        return nil
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    let attributes: [NSAttributedString.Key : Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .paragraphStyle: paragraphStyle
    ]

    var offsetY: CGFloat = 20
    func drawLine(_ line: String, extraSpacing: CGFloat = 20) {
        let attributed = NSAttributedString(string: line, attributes: attributes)
        attributed.draw(in: CGRect(x: 20, y: offsetY, width: 500, height: 1000))
        offsetY += extraSpacing
    }

    drawLine("Transactions Report\n", extraSpacing: 30)
    for s in shifts {
        let hours = s.duration / 3600.0
        let earnings = hours * 15.0
        let line = "• \(formattedShiftDate(for: s.startTime)) [\(formattedTime(s.startTime)) - \(formattedTime(s.endTime))], " +
                   "Hrs: \(String(format:"%.2f", hours)), Earned: $\(String(format:"%.2f", earnings))"
        drawLine(line)
    }

    UIGraphicsEndPDFContext()

    if FileManager.default.fileExists(atPath: pdfURL.path) {
        return pdfURL
    } else {
        return nil
    }
}

// MARK: - Preview
struct TransactionsGesture_Previews: PreviewProvider {
    @Namespace static var previewNamespace
    static var previews: some View {
        TransactionsGesture(showTransactions: .constant(true), namespace: previewNamespace)
    }
}
