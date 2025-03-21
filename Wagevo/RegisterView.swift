//
//  RegisterView.swift
//  Wagevo
//
//  Created by Carter Hammond on 1/31/25.
//

import SwiftUI
import Supabase
import AnyCodable

/// Utility function to parse either "yyyy-MM-dd" or ISO8601 date strings
private func flexibleDate(from string: String) -> Date? {
    let simple = DateFormatter()
    simple.dateFormat = "yyyy-MM-dd"
    if let d = simple.date(from: string) { return d }
    let iso = ISO8601DateFormatter()
    return iso.date(from: string)
}

// MARK: - UserProfile Model
struct UserProfile: Codable, Identifiable {
    let userid: String
    let first_name: String
    let last_name: String
    let email: String
    let phone: String
    let birthday: Date
    let employer_id: String?
    let role_id: Int?
    
    var id: String { userid }
    
    enum CodingKeys: String, CodingKey {
        case userid, first_name, last_name, email, phone, birthday, employer_id, role_id
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        userid      = try c.decode(String.self, forKey: .userid)
        first_name  = try c.decode(String.self, forKey: .first_name)
        last_name   = try c.decode(String.self, forKey: .last_name)
        email       = try c.decode(String.self, forKey: .email)
        phone       = try c.decode(String.self, forKey: .phone)
        
        let rawBday = try c.decode(String.self, forKey: .birthday)
        guard let date = flexibleDate(from: rawBday) else {
            throw DecodingError.dataCorruptedError(
                forKey: .birthday,
                in: c,
                debugDescription: "Could not parse \(rawBday)"
            )
        }
        birthday    = date
        employer_id = try c.decodeIfPresent(String.self, forKey: .employer_id)
        role_id     = try c.decodeIfPresent(Int.self,    forKey: .role_id)
    }
    
    init(userid: String, first_name: String, last_name: String, email: String, phone: String, birthday: Date, employer_id: String?, role_id: Int?) {
        self.userid = userid
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.phone = phone
        self.birthday = birthday
        self.employer_id = employer_id
        self.role_id = role_id
    }
}

// MARK: - UserProfileStore
@MainActor
class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile?
    
    func fetchProfile() async throws -> UserProfile {
        // If there's no active session, throw
        guard let session = try? await SupabaseManager.shared.supabase.auth.session else {
            throw NSError(domain: "SupabaseError", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No session"])
        }
        let userID = session.user.id.uuidString
        
        let response = try await SupabaseManager.shared.supabase
            .from("accounts")
            .select("userid, first_name, last_name, email, phone, birthday, employer_id, role_id")
            .eq("userid", value: userID)
            .execute()
        
        guard let rawArr = response.value as? [[String: Any]],
              let firstRow = rawArr.first else {
            throw NSError(domain: "SupabaseError", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No row found or invalid response"])
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: firstRow, options: [])
        let decoder = JSONDecoder()
        let fetched = try decoder.decode(UserProfile.self, from: jsonData)
        
        DispatchQueue.main.async {
            self.profile = fetched
        }
        return fetched
    }
}

// Shared instance for easy access
@MainActor
var sharedUserProfileStore = UserProfileStore()

// MARK: - Extend AuthManager for Async Sign Up
extension AuthManager {
    func signUpAsync(
        email: String,
        password: String,
        extraData: [String: AnyJSON]? = nil
    ) async throws -> Session {
        try await withCheckedThrowingContinuation { continuation in
            self.signUp(email: email, password: password, extraData: extraData) { result in
                switch result {
                case .success(let session):
                    continuation.resume(returning: session)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - RegisterView (No Local Fallback)
@MainActor
struct RegisterView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Binding var showSignUp: Bool
    
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var email     = ""
    @State private var phoneNumber = ""
    @State private var password  = ""
    @State private var birthday  = Date()
    
    // For demo; normally from real employer
    private let dummyEmployerID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
    @State private var currentPage = 0
    @State private var isRegistered = false
    private let totalPages = 6
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    TabView(selection: $currentPage) {
                        InputPageRegister(
                            title: "First Name",
                            text: $firstName,
                            keyboardType: .default,
                            isSecure: false,
                            capitalize: true,
                            onNext: nextPage
                        )
                        .tag(0)
                        
                        InputPageRegister(
                            title: "Last Name",
                            text: $lastName,
                            keyboardType: .default,
                            isSecure: false,
                            capitalize: true,
                            onNext: nextPage
                        )
                        .tag(1)
                        
                        InputPageRegister(
                            title: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            isSecure: false,
                            capitalize: false,
                            onNext: nextPage,
                            validate: isValidEmail
                        )
                        .tag(2)
                        
                        InputPageRegister(
                            title: "Phone Number",
                            text: $phoneNumber,
                            keyboardType: .phonePad,
                            isSecure: false,
                            capitalize: false,
                            onNext: nextPage,
                            validate: isValidPhoneNumber
                        )
                        .tag(3)
                        
                        InputPageRegister(
                            title: "Password",
                            text: $password,
                            keyboardType: .default,
                            isSecure: true,
                            capitalize: false,
                            onNext: nextPage,
                            validate: isValidPassword
                        )
                        .tag(4)
                        
                        BirthdayInputPageRegister(
                            birthday: $birthday,
                            onNext: completeRegistration
                        )
                        .tag(5)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    Spacer()
                    
                    // Next or Finish button
                    Button {
                        if currentPage < totalPages - 1 {
                            if validateCurrentPage() {
                                UserInfo.shared.update(
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    phoneNumber: phoneNumber,
                                    password: password,
                                    birthday: birthday
                                )
                                provideSuccessHaptic()
                                withAnimation { currentPage += 1 }
                            } else {
                                provideErrorHaptic()
                            }
                        } else {
                            if validateCurrentPage() {
                                UserInfo.shared.update(
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    phoneNumber: phoneNumber,
                                    password: password,
                                    birthday: birthday
                                )
                                provideSuccessHaptic()
                                completeRegistration()
                            } else {
                                provideErrorHaptic()
                            }
                        }
                    } label: {
                        rPillButton(
                            title: currentPage == totalPages - 1 ? "Finish" : "Next",
                            color: isInputValid() ? Color.accentColor : Color.accentColor.opacity(0.5)
                        )
                    }
                    .disabled(!isInputValid())
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            
            // Progress bar
            VStack {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.accentColor)
                        .frame(
                            width: (geo.size.width / CGFloat(totalPages)) * CGFloat(currentPage),
                            height: 4
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
                .frame(height: 4)
                Spacer()
            }
            
            // Error banner
            if showError {
                VStack {
                    Text(errorMessage)
                        .font(.callout)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 16)
                        .frame(width: 350)
                        .background(Capsule().fill(Color.red))
                        .transition(.opacity)
                    Spacer()
                }
                .padding(.top, 20)
                .animation(.easeInOut(duration: 0.3), value: showError)
            }
            
            // Success overlay
            if isRegistered {
                RegisteredWelcomeViewFullScreenRegister {
                    withAnimation(.easeInOut(duration: 1)) {
                        hasCompletedOnboarding = true
                        showSignUp = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .overlay(
            // Top-right exit button
            Group {
                if !isRegistered {
                    Button {
                        showSignUp = false
                        provideSuccessHaptic()
                    } label: {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(Color.accentColor)
                            .cornerRadius(30)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 25)
                }
            },
            alignment: .topTrailing
        )
    }
    
    // MARK: - Validation and Navigation
    
    private func nextPage() {
        if currentPage < totalPages - 1, validateCurrentPage() {
            UserInfo.shared.update(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                password: password,
                birthday: birthday
            )
            withAnimation { currentPage += 1 }
        }
    }
    
    func rPillButton(title: String, color: Color) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 350, height: 75)
            .background(color)
            .cornerRadius(40)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty { return true }
        let regex = try! NSRegularExpression(
            pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
            options: .caseInsensitive
        )
        return regex.firstMatch(in: email, options: [],
                                range: NSRange(location: 0, length: email.utf16.count)) != nil
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^\\d{10}$", options: .caseInsensitive)
        return regex.firstMatch(in: phoneNumber, options: [],
                                range: NSRange(location: 0, length: phoneNumber.utf16.count)) != nil
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        if password.count < 8 {
            showError(message: "Password must be at least 8 characters.")
            return false
        }
        return true
    }
    
    private func isAtLeast16YearsOld(birthday: Date) -> Bool {
        let age = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        return age >= 16
    }
    
    private func isInputValid() -> Bool {
        switch currentPage {
        case 0: return !firstName.isEmpty
        case 1: return !lastName.isEmpty
        case 2: return isValidEmail(email)
        case 3: return !phoneNumber.isEmpty && isValidPhoneNumber(phoneNumber)
        case 4: return !password.isEmpty
        case 5: return isAtLeast16YearsOld(birthday: birthday)
        default: return false
        }
    }
    
    private func validateCurrentPage() -> Bool {
        switch currentPage {
        case 0:
            guard !firstName.isEmpty else {
                showError(message: "Please enter your first name.")
                return false
            }
        case 1:
            guard !lastName.isEmpty else {
                showError(message: "Please enter your last name.")
                return false
            }
        case 2:
            guard isValidEmail(email) else {
                showError(message: "Please enter a valid email.")
                return false
            }
        case 3:
            guard isValidPhoneNumber(phoneNumber) else {
                showError(message: "Please enter a valid 10-digit phone number.")
                return false
            }
        case 4:
            guard isValidPassword(password) else {
                return false
            }
        case 5:
            guard isAtLeast16YearsOld(birthday: birthday) else {
                showError(message: "You must be at least 16 years old to register.")
                return false
            }
        default:
            break
        }
        return true
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showError = false }
        }
    }
    
    // MARK: - Complete Registration (No Local Fallback)
    private func completeRegistration() {
        UserInfo.shared.update(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            password: password,
            birthday: birthday
        )
        provideSuccessHaptic()
        
        Task {
            do {
                // 1) Convert birthday to "yyyy-MM-dd" string
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                let bdayString = fmt.string(from: birthday)
                
                // 2) Extra user metadata
                let extraData: [String: AnyJSON] = [
                    "role_id":     try AnyJSON(AnyCodable("1")),
                    "birthday":    try AnyJSON(AnyCodable(bdayString)),
                    "first_name":  try AnyJSON(AnyCodable(firstName)),
                    "last_name":   try AnyJSON(AnyCodable(lastName)),
                    "phone":       try AnyJSON(AnyCodable(phoneNumber)),
                    "employer_id": try AnyJSON(AnyCodable(dummyEmployerID.uuidString))
                ]
                
                // 3) Sign up using AuthManager
                let session = try await AuthManager.shared.signUpAsync(
                    email: email,
                    password: password,
                    extraData: extraData
                )
                print("SignUp success =>", session)
                
                // 4) Upsert a row in "accounts"
                let newUserID = session.user.id.uuidString
                
                let userRow: [String: AnyCodable] = [
                    "userid":     AnyCodable(newUserID),
                    "email":      AnyCodable(email),
                    "phone":      AnyCodable(phoneNumber),
                    "birthday":   AnyCodable(bdayString),
                    "first_name": AnyCodable(firstName),
                    "last_name":  AnyCodable(lastName),
                    "role_id":    AnyCodable(1),
                    "employer_id": AnyCodable(dummyEmployerID.uuidString)
                ]
                
                _ = try await SupabaseManager.shared.supabase
                    .from("accounts")
                    .upsert([userRow], onConflict: "userid")
                    .execute()
                
                // 5) Fetch the user profile
                let prof = try await sharedUserProfileStore.fetchProfile()
                print("Profile fetch =>", prof)
                
                // 6) Registration successful
                isRegistered = true
                
            } catch {
                // Show error instead of local fallback
                showError(message: error.localizedDescription)
                print("Registration error: \(error.localizedDescription)")
            }
        }
    }
    
    private func provideSuccessHaptic() {
        let gen = UIImpactFeedbackGenerator(style: .rigid)
        gen.impactOccurred()
    }
    
    private func provideErrorHaptic() {
        let gen = UIImpactFeedbackGenerator(style: .rigid)
        gen.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            gen.impactOccurred(intensity: 1.0)
        }
    }
}

// MARK: - InputPageRegister
struct InputPageRegister: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    var isSecure: Bool
    var capitalize: Bool
    var onNext: () -> Void
    var validate: ((String) -> Bool)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 100)
                .padding(.bottom, 10)
                .offset(y: -80)
            
            Group {
                if isSecure {
                    SecureField("Type here...", text: $text)
                        .submitLabel(.next)
                        .onSubmit { onNext() }
                } else {
                    TextField("Type here...", text: $text)
                        .submitLabel(.next)
                        .onSubmit { onNext() }
                }
            }
            .foregroundColor(.white)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(capitalize ? .words : .none)
            .focused($isFocused)
            .modifier(PurpleLineFieldStyleRegister(isFocused: isFocused))
        }
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - BirthdayInputPageRegister
struct BirthdayInputPageRegister: View {
    @Binding var birthday: Date
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Birthday")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 60)
                .padding(.bottom, 20)
            
            DatePicker("", selection: $birthday, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(width: 350, height: 150)
                .accentColor(.white)
                .preferredColorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - RegisteredWelcomeViewFullScreenRegister
struct RegisteredWelcomeViewFullScreenRegister: View {
    var onCompletion: () -> Void
    @State private var show = false
    @State private var scale: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                ZStack {
                    // Masked layer using a dummy Color view masked by the checkmark icon
                    Color.clear
                        .mask(
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .scaleEffect(scale)
                        )
                    // Foreground checkmark icon
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.accentColor)
                        .opacity(show ? 0 : 1)
                        .scaleEffect(scale)
                }
                Text("Welcome to Wagevo!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1).delay(0.5)) {
                scale = 0.8
            }
            withAnimation(.spring(duration: 1).delay(1)) {
                show = true
                scale = 20
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onCompletion()
            }
        }
    }
}

// MARK: - PurpleLineFieldStyleRegister
struct PurpleLineFieldStyleRegister: ViewModifier {
    var isFocused: Bool
    @State private var fieldWidth: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { fieldWidth = geo.size.width }
                }
            )
            .overlay(
                VStack {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 2)
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: isFocused ? fieldWidth : 0, height: 2)
                            .animation(.easeInOut(duration: 0.3), value: isFocused)
                    }
                }
            )
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(showSignUp: .constant(true))
    }
}
