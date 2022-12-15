//
//  AuthService.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

protocol AuthServiceProtocol {
    /// Write the authentication data to a secure storage. If there is such a user, it will update the password.
    /// - Parameters:
    ///   - id: The user ID in the database.
    ///   - login: User login.
    ///   - pass: User password.
    func setLoginPass(id: String, login: String, pass: String)
    /// Get the user's database ID in the secure storage.
    /// - Parameter login: User login.
    /// - Returns: If there is such a login, it will return the database ID.
    func getId(_ login: String) -> String?
    /// Get the password by login.
    /// - Parameter login: User login.
    /// - Returns: If there is such a login, it will return the password.
    func getPassword(_ login: String) -> String?
    /// Delete login and password from secure storage.
    /// - Parameter login: User login.
    func deleteLoginPass(_ login: String)
}

final class AuthService: AuthServiceProtocol {
    // MARK: - Private Properties

    private lazy var keychain = KeychainHelper()

    // MARK: - Public Properties
    
    func getId(_ login: String) -> String? {
        let logins = keychain.get(key: .logins)
        return logins?[login]
    }

    func getPassword(_ login: String) -> String? {
        guard let logins = keychain.get(key: .logins),
              let id = logins[login],
              let passwords = keychain.get(key: .passwords) else { return nil }

        return passwords[id]
    }

    func deleteLoginPass(_ login: String) {
        var logins = keychain.get(key: .logins)
        var passwords = keychain.get(key: .passwords)

        if let id = logins?.removeValue(forKey: login) {
            passwords?.removeValue(forKey: id)
        }
    }

    func setLoginPass(id: String, login: String, pass: String) {
        var logins = keychain.get(key: .logins) ?? [:]
        var passwords = keychain.get(key: .passwords) ?? [:]

        logins[login] = id
        passwords[id] = pass
        keychain.set(logins, key: .logins)
        keychain.set(passwords, key: .passwords)
    }
}
