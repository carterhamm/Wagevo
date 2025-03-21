//
//  Tabs.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI

struct Tabs: View {
    @State private var selectedTab = 2  // 0: Bank, 1: Payroll, 2: Time Clock, 3: Calendar, 4: Profile

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                BankView()
            }
            .tabItem {
                Label("Bank", systemImage: selectedTab == 0 ? "building.columns.fill" : "building.columns")
            }
            .tag(0)
            
            NavigationStack {
                PayView()
            }
            .tabItem {
                Label("Payroll", systemImage: selectedTab == 1 ? "banknote.fill" : "banknote")
            }
            .tag(1)
            
            NavigationStack {
                TimeClock()
            }
            .tabItem {
                Label("Time Clock", systemImage: selectedTab == 2 ? "clock.fill" : "clock")
            }
            .tag(2)
            
            NavigationStack {
                CalendarViewV1()
            }
            .tabItem {
                Label("Calendar", systemImage: selectedTab == 3 ? "calendar" : "calendar")
            }
            .tag(3)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: selectedTab == 4 ? "gearshape.fill" : "gearshape")
            }
            .tag(4)
        }
    }
}

struct DebitCardView: View {
    var body: some View {
        Text("Debit Card Details")
    }
}

#Preview {
    Tabs()
}
