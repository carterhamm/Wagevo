//
//  WageShift.swift
//  Wagevo
//
//  Created by Carter Hammond on [Today’s Date].
//

import Foundation
import Supabase
import AnyCodable

// MARK: - Supabase Manager
class SupabaseManager {
    static let shared = SupabaseManager()
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://iwkxkfsynkvuptxwejgk.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3a3hrZnN5bmt2dXB0eHdlamdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyNTIzMjIsImV4cCI6MjA1NDgyODMyMn0.Q4v7hqG2vE4ECxi58XJ9pC58gx7KIDDmvXrXGBjCee8"
    )
}

// MARK: - Shift Functions

// Returns locally saved shifts using the Shift model from your ShiftModel.swift file.
func getPreviousShifts() -> [Shift] {
    if let data = UserDefaults.standard.data(forKey: "savedShifts"),
       let shifts = try? JSONDecoder().decode([Shift].self, from: data) {
        return shifts
    }
    return []
}

// FormattedDate
public func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d"
    return formatter.string(from: date)
}

// If you don’t want to redeclare saveShift(…) from ShiftModel.swift, you can remove this if it’s already defined.
// (Make sure the type matches: here we assume Shift rather than WageShift.)
func saveShift(_ newShift: Shift) {
    var shifts = getPreviousShifts()
    shifts.append(newShift)
    if let encoded = try? JSONEncoder().encode(shifts) {
        UserDefaults.standard.set(encoded, forKey: "savedShifts")
    }
}

// This helper computes total hours in the last 7 days based on the saved Shift objects.
func formatHoursInLast7Days() -> String {
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    let recentShifts = getPreviousShifts().filter { shift in
        return shift.startTime >= sevenDaysAgo && shift.startTime <= Date()
    }
    // Sum the durations stored in each shift.
    let totalDuration = recentShifts.reduce(0.0) { $0 + $1.duration }
    let hrs = Int(totalDuration) / 3600
    let mins = (Int(totalDuration) % 3600) / 60
    if hrs > 0 && mins > 0 {
        return "\(hrs)h \(mins)m"
    } else if hrs > 0 {
        return "\(hrs)h"
    } else {
        return "\(mins)m"
    }
}

// MARK: - Expense Model and Functions

struct Expense: Codable, Identifiable {
    let id: String
    let date: Date
    let amount: Double
    let isIncome: Bool
}

func getPreviousExpenses() -> [Expense] {
    if let data = UserDefaults.standard.data(forKey: "savedExpenses"),
       let expenses = try? JSONDecoder().decode([Expense].self, from: data) {
        return expenses
    }
    return []
}

func saveExpense(_ newExpense: Expense) {
    var expenses = getPreviousExpenses()
    expenses.append(newExpense)
    if let encoded = try? JSONEncoder().encode(expenses) {
        UserDefaults.standard.set(encoded, forKey: "savedExpenses")
    }
}

// MARK: - WageShift Model

struct WageShift: Codable, Identifiable {
    // Our on-device shift ID (iOSShiftID)
    let id: String
    let time_in: String    // ISO8601 formatted string
    let time_out: String?
    let start_break: String?
    let stop_break: String?
    let hours_worked: Double?
    let user_id: String
    let employer_id: String
    let transaction_id: String?
    let earnings: Double?
}

// Generate a unique on-device shift ID (iOSShiftID)
func generateiOSShiftID() -> String {
    return "iOS" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
}

// MARK: - ShiftService

class ShiftService {
    static let shared = ShiftService()
    let supabase = SupabaseManager.shared.supabase
    
    // Clock In: Inserts a new shift record using our generated iOSShiftID.
    func clockIn(userID: String, employerID: String, completion: @escaping (Result<WageShift, Error>) -> Void) {
        let now = Date()
        let isoFormatter = ISO8601DateFormatter()
        let timeInString = isoFormatter.string(from: now)
        let iOSShiftID = generateiOSShiftID()
        
        let newShift = WageShift(
            id: iOSShiftID,
            time_in: timeInString,
            time_out: nil,
            start_break: nil,
            stop_break: nil,
            hours_worked: nil,
            user_id: userID,
            employer_id: employerID,
            transaction_id: nil,
            earnings: nil
        )
        
        Task {
            do {
                let insertedShifts: [WageShift] = try await supabase
                    .from("shifts")
                    .insert(newShift)
                    .select()
                    .execute()
                    .value
                if let shift = insertedShifts.first {
                    completion(.success(shift))
                } else {
                    let error = NSError(domain: "ShiftService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Shift not created."])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Clock Out: Updates an existing shift record.
    func clockOut(iOSShiftID: String, timeOut: Date, hoursWorked: Double, earnings: Double, completion: @escaping (Result<WageShift, Error>) -> Void) {
        let isoFormatter = ISO8601DateFormatter()
        let timeOutString = isoFormatter.string(from: timeOut)
        
        // Create updateData as [String: AnyJSON]
        let updateData: [String: AnyJSON] = [
            "time_out": try! AnyJSON(timeOutString),
            "hours_worked": try! AnyJSON(hoursWorked),
            "earnings": try! AnyJSON(earnings)
        ]
        
        Task {
            do {
                let updatedShifts: [WageShift] = try await supabase
                    .from("shifts")
                    .update(updateData)
                    .eq("id", value: iOSShiftID)
                    .select()
                    .execute()
                    .value
                if let shift = updatedShifts.first {
                    completion(.success(shift))
                } else {
                    let error = NSError(domain: "ShiftService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Shift update failed."])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
