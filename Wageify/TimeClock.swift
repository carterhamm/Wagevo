//
//  TimeClock.swift
//  Wageify
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI

struct TimeClock: View {

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.05 // 5% padding on each side
            let usableWidth = geometry.size.width - (horizontalPadding * 2)

            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth // Medium tiles span full usable width

            ScrollView {

                VStack {
                        // ✅ Large Tile (Fixed)
                    ZStack {
                        VStack {
                            NavigationLink(destination: DebitCardView()) {
                                bankTile(title: "Time Clock", icon: "clock.fill", width: mediumTileWidth)
                                // ✅ Pass `width`
                            }
                        }
                        VStack {
                            Spacer()
                            largeInfo()
                                .padding(.bottom, 2.0)
                        }
                    }
                    
                    // ✅ Previous Shifts Tile
                    ZStack {
                        VStack {
                            // ✅ Title (takes up 30% of the tile)
                            NavigationLink(destination: PreviousShiftsView()) {
                                mediumTile(title: "Previous Shifts", icon: "clock.arrow.circlepath", width: mediumTileWidth)
                            }
                        }


                        VStack {
                            let shifts = getPreviousShifts().suffix(3)
                            let count = shifts.count

                            Spacer(minLength: 50) // ✅ Pushes shifts downward

                            ForEach(shifts.indices, id: \.self) { index in
                                let shift = shifts[index]

                                HStack {
                                    Text(formatDate(shift.startTime))
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Text(formatDuration(shift.duration))
                                        .fontWeight(.light)
                                }
                                .padding(.vertical, 4) // ✅ Consistent vertical padding

                                if index < count - 1 {
                                    Divider() // ✅ Separates shifts for clarity
                                }
                            }

                            Spacer(minLength: 10) // ✅ Prevents shifts from touching the bottom
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 110) // ✅ Restricts shifts to the bottom 70% of the tile
                    }
                    .frame(width: mediumTileWidth, height: 180) // ✅ Full tile size
                    .padding(.top)

                    // ✅ Small and Extra Small Tiles
                    HStack {
                        // Small Tile
                        ZStack {
                            VStack {
                                NavigationLink(destination: DebitCardView()) {
                                    smallTile(title: "Hours", icon: "clock.fill", width: smallTileWidth)
                                    // ✅ Pass `width`
                                }
                            }
                            VStack {
                                HStack {
                                    Text("Last 7 days")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .padding(.trailing, 5.0)
                                        .padding(.top, 45)
                                        .padding(.leading, 3)
                                    Spacer()
                                }
                            }
                            VStack {
                                Spacer()
                                HStack {
                                    Text("19h 23m")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .foregroundColor(Color("AccentColor"))
                                        .padding()
                                        .padding(.leading, 3.0)
                                    Spacer()
                                }
                            }

                        }
                        .clipped()
                        
                        Spacer()

                            // Small Tile
                            ZStack {
                                VStack {
                                    NavigationLink(destination: DebitCardView()) {
                                        smallTile(title: "Est. Pay", icon: "dollarsign.circle.fill", width: smallTileWidth)
                                        // ✅ Pass `width`
                                    }
                                }
                                VStack {
                                    HStack {
                                        Text("Feb 5")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                            .padding(.trailing, 5.0)
                                            .padding(.top, 45)
                                            .padding(.leading, 3)
                                        Spacer()
                                    }
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("$347.86")
                                            .font(.largeTitle)
                                            .fontWeight(.heavy)
                                            .foregroundColor(Color("AccentColor"))
                                            .padding()
                                            .padding(.leading, 3.0)
                                        Spacer()
                                    }
                                }

                            }
                            .clipped()


                    }
                    .padding(.vertical)
                    
                    // ✅ Upcoming Shifts Tile
                    ZStack {
                        VStack {
                            NavigationLink(destination: DebitCardView()) {
                                mediumTile(title: "Upcoming Shifts", icon: "stopwatch.fill", width: mediumTileWidth) // ✅ Pass `width`
                            }
                        }
                        .padding(.vertical)
                        
                        
                        VStack {
                            HStack {
                                Text("February 4")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text("8:00 AM - 2:00 PM")
                                    .fontWeight(.light)
                            }
                            .padding(.bottom, 5)
                            .padding(.top, 35)
                            HStack {
                                Text("February 9")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text("6:00 PM - 10:00PM")
                                    .fontWeight(.light)
                            }
                            .padding(.vertical, 6)
                            HStack {
                                Text("February 21")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text("4:30 PM - 10:00PM")
                                    .fontWeight(.light)
                            }
                            .padding(.vertical, 6)
                        }
                        .padding()
                    }
                    .frame(width: mediumTileWidth, height: 180)
                    .padding(.vertical, 5)
                }
                .padding(.horizontal, horizontalPadding) // Consistent edge padding
            }
            .navigationTitle("Time Clock")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Formatting Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Example: "Feb 2"
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours) hrs, \(minutes) min"
    }
    
    // Function to provide haptic feedback
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
}

#Preview {
    TimeClock()
}
