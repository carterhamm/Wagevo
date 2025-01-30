//
//  PreviousShifts.swift
//  Wageify
//
//  Created by Carter Hammond on 1/26/25.
//

import SwiftUI

struct Tabs: View {
    var body: some View {
        TabView {
            NavigationView {
                BankView()
            }
            .tabItem {
                Label("Bank", systemImage: "building.columns")
            }
            
            NavigationView {
                PayView()
            }
            .tabItem {
                Label("Payroll", systemImage: "banknote")
            }
            
            NavigationView {
                TimeClock()
            }
            .tabItem {
                Label("Time Clock", systemImage: "clock")
            }
            
            NavigationView {
                CalendarViewV1()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
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
