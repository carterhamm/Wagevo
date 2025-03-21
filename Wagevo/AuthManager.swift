import Foundation
import Supabase
import AnyCodable

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://iwkxkfsynkvuptxwejgk.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3a3hrZnN5bmt2dXB0eHdlamdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyNTIzMjIsImV4cCI6MjA1NDgyODMyMn0.Q4v7hqG2vE4ECxi58XJ9pC58gx7KIDDmvXrXGBjCee8"
    )
    
    @Published var session: Session?
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                let newSession = try await supabase.auth.signIn(email: email, password: password)
                self.session = newSession
                completion(.success(newSession.user))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sign Up
    /// Creates a new user in Supabase Auth and updates the published `session`.
    /// - Parameters:
    ///   - email: The new user's email.
    ///   - password: The new user's password.
    ///   - extraData: Additional user metadata you want to store (e.g., first_name, last_name).
    ///   - completion: Returns a `Result<Session, Error>` upon success or failure.
    func signUp(
        email: String,
        password: String,
        extraData: [String: AnyJSON]? = nil,
        completion: @escaping (Result<Session, Error>) -> Void
    ) {
        Task {
            do {
                // 1) Create the user in Supabase Auth
                _ = try await supabase.auth.signUp(email: email, password: password, data: extraData)
                
                // 2) Retrieve the current session after sign-up
                let currentSession = try await supabase.auth.session
                self.session = currentSession
                
                completion(.success(currentSession))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Logout
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await supabase.auth.signOut()
                self.session = nil
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
