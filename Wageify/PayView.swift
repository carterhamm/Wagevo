//
//  PayView.swift
//  Wageify
//
//  Created by Carter Hammond on 1/29/25.
//

import SwiftUI

struct PayView: View {
    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = geometry.size.width * 0.05
            let usableWidth = geometry.size.width - (horizontalPadding * 2)

            let smallTileWidth = (usableWidth - 14) / 2
            let mediumTileWidth = usableWidth

            ScrollView {
                VStack {
                    // ✅ Upcoming Paycheck Tile
                    NavigationLink(destination: DebitCardView()) {
                        ZStack {
                            VStack {
                                payTile(title: "Upcoming Paycheck", icon: "calendar", width: mediumTileWidth)
                            }
                            .padding(.vertical)

                            VStack {
                                Spacer()
                                HStack {
                                    Text("$521.39")
                                        .font(.system(size: mediumTileWidth * 0.19, weight: .heavy))
                                        .foregroundColor(Color("AccentColor"))
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                        .padding(.leading, 5.0)
                                    Spacer()
                                }
                                .padding(.bottom, 15)
                                .padding(.top, 35)
                            }
                            .padding()
                        }
                        .frame(width: mediumTileWidth, height: 180)
                        .padding(.top)
                    }
                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                    .contextMenu {
                        NavigationLink(destination: DebitCardView()) {
                            Label("View Paycheck Details", systemImage: "dollarsign.circle")
                        }
                    }

                    // ✅ Previous Paychecks Tile
                    NavigationLink(destination: DebitCardView()) {
                        ZStack {
                            VStack {
                                mediumTile(title: "Previous Paychecks", icon: "doc.text", width: mediumTileWidth)
                            }
                            .padding(.vertical)

                            VStack {
                                HStack {
                                    Text("Dec 17").fontWeight(.semibold)
                                    Spacer()
                                    Text("$142.50").fontWeight(.light)
                                }
                                .padding(.bottom, 5)
                                .padding(.top, 35)
                                HStack {
                                    Text("Jan 12").fontWeight(.semibold)
                                    Spacer()
                                    Text("$230.00").fontWeight(.light)
                                }
                                .padding(.vertical, 6)
                                HStack {
                                    Text("Jan 22").fontWeight(.semibold)
                                    Spacer()
                                    Text("$198.75").fontWeight(.light)
                                }
                                .padding(.vertical, 6)
                            }
                            .padding()
                            .padding(.horizontal, 4)
                            .padding(.top, 10)
                        }
                        .frame(width: mediumTileWidth, height: 180)
                        .padding(.top)
                    }
                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                    .contextMenu {
                        NavigationLink(destination: DebitCardView()) {
                            Label("View Previous Paychecks", systemImage: "doc.text")
                        }
                    }

                    // ✅ Small and Extra Small Tiles
                    HStack {
                        // ✅ Last Shift Tile
                        NavigationLink(destination: DebitCardView()) {
                            ZStack {
                                VStack {
                                    smallTile(title: "Last Shift", icon: "clock.arrow.circlepath", width: smallTileWidth)
                                }
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("$81.60")
                                            .font(.system(size: mediumTileWidth * 0.12, weight: .heavy))
                                            .foregroundColor(Color("AccentColor"))
                                            .minimumScaleFactor(0.8)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("6 hrs, 45 min")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                            .padding(.trailing, 5.0)
                                            .padding(.leading, 2.0)
                                        Spacer()
                                    }
                                }
                            }
                            .clipped()
                        }
                        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                        .contextMenu {
                            NavigationLink(destination: DebitCardView()) {
                                Label("View Shift Details", systemImage: "clock")
                            }
                        }

                        Spacer()

                        // ✅ Deposits & Withdrawals Tiles
                        VStack(spacing: 12) {
                            ForEach(["Blank", "Blank"], id: \.self) { title in
                                NavigationLink(destination: DebitCardView()) {
                                    ZStack {
                                        VStack {
                                            xSmallTile(title: title, width: smallTileWidth)
                                        }
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Text(title == "Blank" ? "Blank" : "Blank")
                                                    .font(.title2)
                                                    .fontWeight(.heavy)
                                                    .foregroundColor(Color("AccentColor"))
                                                    .padding()
                                                    .padding(.leading, 3.0)
                                                Spacer()
                                            }
                                        }
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("Blank")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .padding(.bottom, 3.0)
                                                    .padding()
                                                    .padding(.trailing, 5.0)
                                            }
                                        }
                                    }
                                    .clipped()
                                }
                                .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                                .contextMenu {
                                    NavigationLink(destination: DebitCardView()) {
                                        Label("View \(title)", systemImage: title == "Deposits" ? "arrow.down.circle" : "arrow.up.circle")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)

                    // ✅ Upcoming Shifts Tile
                    NavigationLink(destination: DebitCardView()) {
                        ZStack {
                            VStack {
                                mediumTile(title: "Blank", icon: "person.circle.fill", width: mediumTileWidth)
                            }
                            .padding(.vertical)

                            VStack {
                                HStack {
                                    Text("Blank").fontWeight(.semibold)
                                    Spacer()
                                    Text("Blank").fontWeight(.light)
                                }
                                .padding(.bottom, 5)
                                .padding(.top, 35)
                                HStack {
                                    Text("Blank").fontWeight(.semibold)
                                    Spacer()
                                    Text("Blank").fontWeight(.light)
                                }
                                .padding(.vertical, 6)
                                HStack {
                                    Text("Blank").fontWeight(.semibold)
                                    Spacer()
                                    Text("Blank").fontWeight(.light)
                                }
                                .padding(.vertical, 6)
                            }
                            .padding()
                            .padding(.horizontal, 4)
                            .padding(.top, 10)
                        }
                        .frame(width: mediumTileWidth, height: 180)
                        .padding(.vertical, 5)
                    }
                    .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() })
                    .contextMenu {
                        NavigationLink(destination: DebitCardView()) {
                            Label("View Upcoming Shifts", systemImage: "calendar")
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .navigationTitle("Pay")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // ✅ Function to Provide Haptic Feedback
    private func provideHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.impactOccurred()
    }
}

#Preview {
    PayView()
}
