//
//  PreviousShiftsView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/29/25.
//

import SwiftUI

struct PreviousShiftsView: View {
    @State private var previousShifts: [Shift] = getPreviousShifts() // Load saved shifts

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.05
            let usableWidth = geometry.size.width - (horizontalPadding * 2)

            ScrollView {
                VStack(spacing: 12) {
                    Text("Previous Shifts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.top)

                    if previousShifts.isEmpty {
                        Text("No shifts recorded yet.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(previousShifts.reversed(), id: \.startTime) { shift in
                            shiftTile(shift: shift, width: usableWidth)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 20)
            }
            .navigationTitle("Shift History")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            previousShifts = getPreviousShifts() // Reload shifts when view appears
        }
    }

    // MARK: - Shift Tile UI
    private func shiftTile(shift: Shift, width: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: 100)
            
            VStack {
                HStack {
                    // ✅ Title inside a pill-shaped background
                    HStack(spacing: 5) {
                        Image(systemName: "clock.fill") // ✅ Clock icon
                            .foregroundColor(.white)
                        Text(shift.startTime.formatted(date: .abbreviated, time: .shortened))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("AccentColor"))
                    )

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("\(formatDuration(shift.duration))")
                        .fontWeight(.light)
                    Spacer()
                }
                .padding(.top, 9)
                
            }
            .padding()
        }
        .frame(maxWidth: width, maxHeight: 100)
        .clipped()
    }
}

// MARK: - Helpers
private func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    return String(format: "%d hr %d min", hours, minutes)
}

#Preview {
    PreviousShiftsView()
}


//Okay now let's go to TimeClock. The above code is the TimeClock page of the app. You'll see that I've put the largeInfo shift stopwatch on the top tile. Right below it is the previous shifts tile
