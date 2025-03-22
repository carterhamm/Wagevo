//
//  ShiftModel.swift
//  Wagevo
//
//  Created by Carter Hammond on [Your Date]
//

import Foundation
import Supabase
import AnyCodable

// MARK: - Shift Model

struct Shift: Codable, Identifiable {
    let shift_id: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let user_id: String
    var isPaid: Bool = false
    
    var id: String { shift_id }
}

// MARK: Demo Shifts (includes “upcoming” so they appear in CalendarView)

private func getDemoShifts() -> [Shift] {
    let cal = Calendar.current
    
    // Completed SHIFT #1: Jan 20, 2025 (6:00 PM - 10:09 PM)
    let s1Start = cal.date(from: DateComponents(year: 2025, month: 1, day: 20, hour: 18, minute: 0))!
    let s1End = cal.date(from: DateComponents(year: 2025, month: 1, day: 20, hour: 22, minute: 9))!
    let s1Duration = s1End.timeIntervalSince(s1Start)
    let shift1 = Shift(shift_id: "demoA", startTime: s1Start, endTime: s1End, duration: s1Duration, user_id: "demoUser")
    
    // Completed SHIFT #2: Jan 24, 2025 (6:00 PM - 10:09 PM)
    let s2Start = cal.date(from: DateComponents(year: 2025, month: 1, day: 24, hour: 18, minute: 0))!
    let s2End = cal.date(from: DateComponents(year: 2025, month: 1, day: 24, hour: 22, minute: 9))!
    let s2Duration = s2End.timeIntervalSince(s2Start)
    let shift2 = Shift(shift_id: "demoB", startTime: s2Start, endTime: s2End, duration: s2Duration, user_id: "demoUser")
    
    // Completed SHIFT #3: Jan 26, 2025 (9:00 AM - 3:00 PM)
    let s3Start = cal.date(from: DateComponents(year: 2025, month: 1, day: 26, hour: 9, minute: 0))!
    let s3End = cal.date(from: DateComponents(year: 2025, month: 1, day: 26, hour: 15, minute: 0))!
    let s3Duration = s3End.timeIntervalSince(s3Start)
    let shift3 = Shift(shift_id: "demoC", startTime: s3Start, endTime: s3End, duration: s3Duration, user_id: "demoUser")
    
    // Completed SHIFT #4: Feb 1, 2025 (8:00 AM - 2:00 PM)
    let s4Start = cal.date(from: DateComponents(year: 2025, month: 2, day: 1, hour: 8, minute: 0))!
    let s4End = cal.date(from: DateComponents(year: 2025, month: 2, day: 1, hour: 14, minute: 0))!
    let s4Duration = s4End.timeIntervalSince(s4Start)
    let shift4 = Shift(shift_id: "demoD", startTime: s4Start, endTime: s4End, duration: s4Duration, user_id: "demoUser")
    
    // “Upcoming SHIFT #5” for demonstration in February 9, 2025 (6 PM - 10 PM)
    let s5Start = cal.date(from: DateComponents(year: 2025, month: 2, day: 9, hour: 18, minute: 0))!
    let s5End = cal.date(from: DateComponents(year: 2025, month: 2, day: 9, hour: 22, minute: 0))!
    let s5Duration = s5End.timeIntervalSince(s5Start)
    let shift5 = Shift(shift_id: "demoE", startTime: s5Start, endTime: s5End, duration: s5Duration, user_id: "demoUser")
    
    // “Upcoming SHIFT #6” for demonstration on Feb 21, 2025 (4:30 PM - 10 PM)
    let s6Start = cal.date(from: DateComponents(year: 2025, month: 2, day: 21, hour: 16, minute: 30))!
    let s6End = cal.date(from: DateComponents(year: 2025, month: 2, day: 21, hour: 22, minute: 0))!
    let s6Duration = s6End.timeIntervalSince(s6Start)
    let shift6 = Shift(shift_id: "demoF", startTime: s6Start, endTime: s6End, duration: s6Duration, user_id: "demoUser")
    
    return [shift1, shift2, shift3, shift4, shift5, shift6]
}

// MARK: - Insert Shift in Supabase + Store Locally

func recordShift(startTime: Date, endTime: Date, hoursWorked: Double) async throws {
    let isoFormatter = ISO8601DateFormatter()
    let timeInString = isoFormatter.string(from: startTime)
    let timeOutString = isoFormatter.string(from: endTime)
    // Generate a unique on-device shift ID (for local purposes only)
    let newShiftID = "iOS" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // Get the current session (this call can throw)
    let session = try await SupabaseManager.shared.supabase.auth.session
    let userID = session.user.id.uuidString
    
    // Prepare the data to be sent to Supabase using AnyCodable.
    let shiftData: [String: AnyCodable] = [
        "time_in": AnyCodable(timeInString),
        "time_out": AnyCodable(timeOutString),
        "hours_worked": AnyCodable(hoursWorked),
        "user_id": AnyCodable(userID)
        // Optionally add "employer_id" here if needed.
    ]
    
    // Insert the new shift record in Supabase.
    let response = try await SupabaseManager.shared.supabase
        .from("shifts")
        .insert([shiftData], returning: .minimal)
        .execute()
    
    guard (200..<300).contains(response.status) else {
        throw NSError(domain: "SupabaseError", code: response.status, userInfo: [NSLocalizedDescriptionKey: "Failed to record shift."])
    }
    
    // Create a new Shift locally.
    let newShift = Shift(
        shift_id: newShiftID,
        startTime: startTime,
        endTime: endTime,
        duration: endTime.timeIntervalSince(startTime),
        user_id: userID
    )
    saveShift(newShift)
}

extension ShiftService {
    func fetchHourlyWage(userID: String, employerID: String, completion: @escaping (Result<Double, Error>) -> Void) {
        // Dummy implementation: Replace with your actual API call if needed.
        completion(.success(15.0))
    }
}
