//
//  CalendarViewV1.swift
//  Wageify
//
//  Created by Carter Hammond on 1/28/25.
//

import SwiftUI

struct CalendarViewV1: View {
    @State private var selectedDate: Date = Date() // Holds the selected date
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let halfHeight = geometry.size.height * 0.5 // Half of the screen height
                
                VStack {
                    // ✅ Calendar on Top
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical) // ✅ Graphical calendar style
                            .frame(height: halfHeight) // Takes half the screen height
                            .clipped()
                    }
                    .frame(height: halfHeight)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6).opacity(0.0))
                    )
                    
                    Divider()

                    // ✅ Selected Date Details (Bottom Half)
                    VStack {
                        Text("Shift Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 10)

                        Text(formattedDate(selectedDate)) // Show formatted date
                            .font(.title3)
                            .foregroundColor(.accentColor)
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // Example Event Details (Placeholder)
                        VStack(alignment: .leading, spacing: 8) {
                            eventRow(title: "Shift Time", value: "9:00 AM - 5:02 PM")
                            eventRow(title: "Total Hours", value: "8 hrs, 2min")
                            eventRow(title: "Earnings", value: "$118.89")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                            // ✅ Purple shadow
                                .shadow(color: Color.purple.opacity(0.3), radius: 7, x: 0, y: 1))
                        
                        Spacer()
                    }
                    .frame(height: halfHeight)
                    .padding()
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// 📌 Function to Format the Date Nicely
private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full // Example: "Monday, January 29, 2025"
    return formatter.string(from: date)
}

// 📌 Event Row for Shift Details
private func eventRow(title: String, value: String) -> some View {
    HStack {
        Text(title)
            .font(.headline)
            .foregroundColor(.gray)
        Spacer()
        Text(value)
            .font(.body)
            .foregroundColor(.primary)
    }
}

#Preview {
    CalendarViewV1()
}
