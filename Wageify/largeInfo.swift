//
//  largeInfo.swift
//  Wageify
//
//  Created by Carter Hammond on 1/27/25.
//

import SwiftUI
import Foundation

struct largeInfo: View {
    @State private var isToggled = false
    @State private var shiftStartTime: Date?
    @State private var shiftDuration: TimeInterval = 0
    @State private var timer: Timer?

    // Calculate screen width and usable width
    private let screenWidth = UIScreen.main.bounds.width
    private let horizontalPadding: CGFloat = 16
    private var usableWidth: CGFloat {
        screenWidth - (horizontalPadding * 2)
    }

    var body: some View {
        VStack(spacing: 10) {
            // Toggle Button
            Button(action: toggleState) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isToggled ? Color("AccentColor").opacity(0.8) : Color("AccentColor"))
                        .frame(width: usableWidth - 48, height: 95)
                        .shadow(radius: 5)

                    HStack(spacing: 12) {
                        Image(systemName: isToggled ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .offset(x: isToggled ? -20 : 0) // ✅ Moves left smoothly
                            .animation(.easeInOut(duration: 0.3), value: isToggled)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(isToggled ? "Clock Out" : "Clock In")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            // ✅ Elapsed Time Appears Smoothly
                            if isToggled {
                                Text("\(formattedElapsedTime())")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.9))
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.3), value: isToggled)
                            }
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(horizontalPadding)
        .padding(.top, 1.0)
        .onDisappear(perform: invalidateTimer)
    }

    // MARK: - Toggle State and Timer Logic
    private func toggleState() {
        isToggled.toggle()

        if isToggled {
            shiftStartTime = Date()
            startTimer()
        } else {
            let endTime = Date()
            saveShift(startTime: shiftStartTime ?? Date(), endTime: endTime, duration: shiftDuration)
            stopAndResetTimer()
        }
    }

    private func startTimer() {
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

    // MARK: - Formatting Elapsed Time
    private func formattedElapsedTime() -> String {
        let hours = Int(shiftDuration) / 3600
        let minutes = (Int(shiftDuration) % 3600) / 60
        let seconds = Int(shiftDuration) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Shift Data Storage
struct Shift: Codable {
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
}

func saveShift(startTime: Date, endTime: Date, duration: TimeInterval) {
    var shifts = getPreviousShifts()
    shifts.append(Shift(startTime: startTime, endTime: endTime, duration: duration))

    if let encoded = try? JSONEncoder().encode(shifts) {
        UserDefaults.standard.set(encoded, forKey: "savedShifts")
    }
}

func getPreviousShifts() -> [Shift] {
    if let savedData = UserDefaults.standard.data(forKey: "savedShifts"),
       let decoded = try? JSONDecoder().decode([Shift].self, from: savedData) {
        return decoded
    }
    return []
}

// MARK: - Preview
#Preview {
    largeInfo()
}
