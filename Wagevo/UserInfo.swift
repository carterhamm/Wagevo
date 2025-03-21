//
//  UserInfo.swift
//  Wagevo
//
//  Created by Carter Hammond on 2/13/25.
//

import Foundation
import Combine

final class UserInfo: ObservableObject {
    static let shared = UserInfo()
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var birthday: Date = Date()
    
    private init() {}
    
    /// Call this method to update the user info with new responses.
    func update(firstName: String, lastName: String, email: String, phoneNumber: String, password: String, birthday: Date) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.birthday = birthday
    }
}
