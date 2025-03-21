//
//  ProfileView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/27/25
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    // Use the shared user profile store.
    @StateObject var profileStore = sharedUserProfileStore
    
    // New state to hold a selected profile image.
    @State private var selectedProfileImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width * 0.04
                let usableWidth = geometry.size.width - (horizontalPadding * 2)
                let mediumTileWidth = usableWidth - 14

                ZStack {
                    (colorScheme == .light ? appleLightGray : Color.black)
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // MARK: Profile Picture Section
                            Group {
                                if let image = selectedProfileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 350, height: 350)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                } else {
                                    // No image yet—display default system image.
                                    Image(systemName: "person.crop.circle.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .resizable()
                                        .frame(width: 350, height: 350)
                                        .foregroundColor(.accentColor)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                }
                            }
                            .padding(.top, 20)
                            .onTapGesture {
                                showImagePicker = true
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(selectedImage: $selectedProfileImage)
                            }
                            
                            // MARK: User's Name (First & Last)
                            if let profile = profileStore.profile {
                                Text("\(profile.first_name) \(profile.last_name)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // MARK: Settings List
                            LazyVStack(spacing: 10) {
                                profileRow(icon: "envelope.circle", title: "Email", value: profileStore.profile?.email ?? "")
                                profileRow(icon: "phone.circle", title: "Phone Number", value: profileStore.profile?.phone ?? "")
                                profileRow(icon: "lock.circle", title: "Password", value: "Change Password")
                                profileRow(icon: "dollarsign.circle", title: "Banking Info", value: "Add/Edit your banking info")
                                // Privacy row now navigates to our secret menu.
                                profileRow(icon: "hand.raised.circle", title: "Privacy", value: "")
                                logOutRow(icon: "arrow.backward.to.line.circle", title: "Log Out")
                            }
                            .frame(width: mediumTileWidth)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, horizontalPadding)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 48)
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// MARK: - Profile Row (General Settings)
private func profileRow(icon: String, title: String, value: String) -> some View {
    NavigationLink(destination: {
        if title == "Privacy" {
            // Updated: navigate to the secret expense menu
            SecretExpenseMenuView()
        } else if title == "Banking Info" {
            BankInfoView()
        } else if title == "Email" {
            EmailUpdateView()
        } else if title == "Phone Number" {
            PhoneNumberUpdateView()
        } else if title == "Password" {
            PasswordUpdateView()
        } else {
            Text("\(title) Details")
        }
    }) {
        HStack {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.accentColor)
                .padding(.leading, 12)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                if !value.isEmpty {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.accentColor)
                .padding(.trailing, 10)
        }
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color(.systemGray6).opacity(0.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(.tint, lineWidth: 2)
                )
        )
    }
}

private func logOutRow(icon: String, title: String) -> some View {
    LogOutRow(icon: icon, title: title)
}

private struct LogOutRow: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
            hasCompletedOnboarding = false // ✅ Resets onboarding so it shows on next launch
        }) {
            HStack {
                Image(systemName: icon)
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .padding(.leading, 12)
                    .padding(.trailing, 5)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(Color.red, lineWidth: 2)
                )
            )
        }
        .simultaneousGesture(TapGesture().onEnded { provideHapticFeedback() }) // ✅ Adds haptic feedback
    }
}

// 📌 Haptic Feedback Function
private func provideHapticFeedback() {
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    impactFeedbackGenerator.impactOccurred()
}

// MARK: - Secret Expense Menu View
/// A view offering options to add a shift or an expense.
struct SecretExpenseMenuView: View {
    var body: some View {
        List {
            NavigationLink(destination: SecretShiftCreationView()) {
                Label("Add Shift", systemImage: "plus.circle")
            }
            NavigationLink(destination: SecretExpenseCreationView()) {
                Label("Add Expense", systemImage: "plus.circle")
            }
        }
        .navigationTitle("Secret Menu")
    }
}

// MARK: - Secret Shift Creation View
/// This view lets you create a new shift.
struct SecretShiftCreationView: View {
    @State private var startTime: Date
    @State private var endTime: Date
    @Environment(\.presentationMode) var presentationMode

    init() {
        // By default, endTime is set to 1 hour after startTime, which is "now" at init.
        let defaultStart = Date()
        let defaultEnd = Calendar.current.date(byAdding: .hour, value: 1, to: defaultStart) ?? defaultStart
        _startTime = State(initialValue: defaultStart)
        _endTime = State(initialValue: defaultEnd)
    }

    var body: some View {
        Form {
            Section(header: Text("Shift Times")) {
                DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                DatePicker("End Time", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
            }
            Section {
                Button("Create Shift") {
                    createShift()
                }
            }
        }
        .navigationTitle("Add Shift")
    }
    
    private func createShift() {
        let duration = endTime.timeIntervalSince(startTime)
        let newShift = Shift(
            shift_id: generateiOSShiftID(),
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            user_id: "secret-user"
        )
        saveShift(newShift)
        NotificationCenter.default.post(name: Notification.Name("ShiftUpdated"), object: nil)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Secret Expense Creation View
/// This view lets you create a new expense.
/// The user selects the date/time and enters an amount.
/// The text field uses a decimal pad keyboard so that only numeric input is allowed.
struct SecretExpenseCreationView: View {
    @State private var expenseDate: Date = Date()
    @State private var amountText: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Expense Details")) {
                DatePicker("Date & Time", selection: $expenseDate, displayedComponents: [.date, .hourAndMinute])
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
            }
            Section {
                Button("Create Expense") {
                    createExpense()
                }
            }
        }
        .background(colorScheme == .light ? appleLightGray : Color.black)
        .navigationTitle("Add Expense")
    }
    
    private func createExpense() {
        guard let amount = Double(amountText) else { return }
        let newExpense = Expense(
            id: generateiOSShiftID(),
            date: expenseDate,
            amount: amount,
            isIncome: false
        )
        saveExpense(newExpense)
        NotificationCenter.default.post(name: Notification.Name("ExpenseUpdated"), object: nil)
        presentationMode.wrappedValue.dismiss()
    }
}

// -----------------------------------------------
// MARK: - BankingInfoView + Subviews for Add/Edit
// -----------------------------------------------

/// A single bank account record, stored in UserDefaults with the rest.
struct BankAccount: Identifiable, Codable {
    let id: UUID
    var routingNumber: String
    var accountNumber: String
    var nickname: String
    
    init(id: UUID = UUID(), routingNumber: String, accountNumber: String, nickname: String) {
        self.id = id
        self.routingNumber = routingNumber
        self.accountNumber = accountNumber
        self.nickname = nickname
    }
}

/// Main view for listing, adding, editing bank info.
struct BankInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var bankAccounts: [BankAccount] = loadBankAccounts()

    var body: some View {
        ZStack {
            // Our background color
            (colorScheme == .light ? appleLightGray : Color.black)
                .ignoresSafeArea()

            VStack {
                if bankAccounts.isEmpty {
                    Text("No bank accounts on file.")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                } else {
                    // Show each bank account in a tile-like row
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(bankAccounts) { account in
                                bankAccountRow(account)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteAccount(account)
                                        } label: {
                                            Label("Remove this account", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("Banking Info")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEditBankInfoView { newAccount in
                        addAccount(newAccount)
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .onAppear {
                bankAccounts = loadBankAccounts()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("BankAccountsUpdated"))) { _ in
                bankAccounts = loadBankAccounts()
            }
        }
    }
    
    // MARK: - Row UI
    private func bankAccountRow(_ account: BankAccount) -> some View {
        NavigationLink(destination: {
            AddEditBankInfoView(editAccount: account) { updatedAccount in
                updateAccount(updatedAccount)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .light ? .white : Color(darkGray))
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 1, y: 1)

                HStack {
                    Image(systemName: "creditcard.fill")
                        .resizable()
                        .frame(width: 30, height: 20)
                        .foregroundColor(.accentColor)
                        .padding(.leading, 12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayBankName(routing: account.routingNumber, nickname: account.nickname))
                            .font(.headline)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        Text("••••\(account.accountNumber.suffix(4))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 6)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.accentColor)
                        .padding(.trailing, 12)
                }
                .frame(height: 60)
            }
            .padding(.horizontal, 10)
        }
    }

    // MARK: - Basic CRUD
    private func addAccount(_ account: BankAccount) {
        var updated = bankAccounts
        updated.append(account)
        saveBankAccounts(updated)
        NotificationCenter.default.post(name: Notification.Name("BankAccountsUpdated"), object: nil)
    }

    private func updateAccount(_ account: BankAccount) {
        var updated = bankAccounts
        if let idx = updated.firstIndex(where: { $0.id == account.id }) {
            updated[idx] = account
            saveBankAccounts(updated)
            NotificationCenter.default.post(name: Notification.Name("BankAccountsUpdated"), object: nil)
        }
    }

    private func deleteAccount(_ account: BankAccount) {
        var updated = bankAccounts
        updated.removeAll(where: { $0.id == account.id })
        saveBankAccounts(updated)
        NotificationCenter.default.post(name: Notification.Name("BankAccountsUpdated"), object: nil)
    }
}

/// Add/Edit subview. If `editAccount` is nil, user is adding a new account.
struct AddEditBankInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State var routingNumber: String = ""
    @State var accountNumber: String = ""
    @State var nickname: String = ""

    var editAccount: BankAccount?
    let onSave: (BankAccount) -> Void

    var body: some View {
        ZStack {
            (colorScheme == .light ? appleLightGray : Color.black)
                .ignoresSafeArea()

            Form {
                Section(header: Text("Account Details")) {
                    TextField("Routing Number", text: $routingNumber)
                        .keyboardType(.numberPad)
                    TextField("Account Number", text: $accountNumber)
                        .keyboardType(.numberPad)
                    TextField("Nickname", text: $nickname)
                }
                .listRowBackground(colorScheme == .light ? Color.white : Color(darkGray))

                Section {
                    Button(editAccount == nil ? "Add Account" : "Save Changes") {
                        saveChanges()
                    }
                }
                .listRowBackground(colorScheme == .light ? Color.white : Color(darkGray))
            }
            .navigationTitle(editAccount == nil ? "Add Bank Account" : "Edit Bank Account")
            .onAppear {
                if let editAcc = editAccount {
                    routingNumber = editAcc.routingNumber
                    accountNumber = editAcc.accountNumber
                    nickname = editAcc.nickname
                }
            }
        }
    }

    private func saveChanges() {
        var newAccount: BankAccount
        if let existing = editAccount {
            newAccount = BankAccount(
                id: existing.id,
                routingNumber: routingNumber,
                accountNumber: accountNumber,
                nickname: nickname
            )
        } else {
            newAccount = BankAccount(
                routingNumber: routingNumber,
                accountNumber: accountNumber,
                nickname: nickname
            )
        }
        onSave(newAccount)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Bank Account Persistence

private func loadBankAccounts() -> [BankAccount] {
    guard let data = UserDefaults.standard.data(forKey: "savedBankAccounts"),
          let decoded = try? JSONDecoder().decode([BankAccount].self, from: data)
    else {
        return []
    }
    return decoded
}

private func saveBankAccounts(_ accounts: [BankAccount]) {
    if let encoded = try? JSONEncoder().encode(accounts) {
        UserDefaults.standard.set(encoded, forKey: "savedBankAccounts")
    }
}

/// Attempt to guess the bank name from a routing number or just use the user's nickname.
private func displayBankName(routing: String, nickname: String) -> String {
    if routing.hasPrefix("0210") {
        return "JPMorgan Chase (\(nickname))"
    } else if routing.hasPrefix("1210") {
        return "Wells Fargo (\(nickname))"
    } else if routing.hasPrefix("1240") {
        return "Bank of America (\(nickname))"
    }
    return nickname.isEmpty ? "Unnamed Bank" : nickname
}

// -----------------------------------------------
// MARK: - New Pages for Email, Phone Number, and Password
// -----------------------------------------------

struct EmailUpdateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Current Email")) {
                Text(email)
            }
            Section(header: Text("Update Email")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            Section {
                Button("Save Changes") {
                    print("Updated email to: \(email)")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Email Details")
        .onAppear {
            if let profile = sharedUserProfileStore.profile {
                email = profile.email
            }
        }
    }
}

struct PhoneNumberUpdateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var phoneNumber: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Current Phone Number")) {
                Text(phoneNumber)
            }
            Section(header: Text("Update Phone Number")) {
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            Section {
                Button("Save Changes") {
                    print("Updated phone number to: \(phoneNumber)")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Phone Number")
        .onAppear {
            if let profile = sharedUserProfileStore.profile {
                phoneNumber = profile.phone
            }
        }
    }
}

struct PasswordUpdateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }
            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            Section {
                Button("Change Password") {
                    if newPassword != confirmPassword {
                        errorMessage = "New passwords do not match."
                    } else if newPassword.isEmpty || currentPassword.isEmpty {
                        errorMessage = "Please fill in all fields."
                    } else {
                        print("Password changed from \(currentPassword) to \(newPassword)")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Password Details")
    }
}

// #Preview remains unchanged
#Preview {
    ProfileView()
}
