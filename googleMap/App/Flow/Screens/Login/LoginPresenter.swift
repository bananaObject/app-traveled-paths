//
//  LoginPresenter.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

import Foundation
import RealmSwift

protocol LoginViewInput: AnyObject {
    /// Shows  allert.
    /// - Parameter tittle: Allert tittle.
    /// - Parameter text: Allert text.
    func showAllert(_ tittle: String, _ text: String)
}

protocol LoginViewOutput: AnyObject {
    /// View requested user registration.
    /// - Parameters:
    ///   - login: User login.
    ///   - pass: User pass.
    func viewRequestedRegistration(_ login: String, _ pass: String)

    /// View requested user login.
    /// - Parameters:
    ///   - login: User login.
    ///   - pass: User pass.
    func viewRequestedLogin(_ login: String, _ pass: String)
}

final class LoginPresenter {
    // MARK: - Public Properties

    /// Screen control.
    weak var viewInput: LoginViewInput?

    // MARK: - Private Properties

    /// Database service.
    private let realm: RealmServiceProtocol
    /// Authorisation service.
    private let auth: AuthServiceProtocol
    /// Transitions between screens.
    private let coordinator: Coordinator

    // MARK: - Initialization

    init(_ realm: RealmServiceProtocol,
         _ auth: AuthServiceProtocol,
         _ coordinator: Coordinator) {
        self.realm = realm
        self.auth = auth
        self.coordinator = coordinator
    }
}

// MARK: - LoginViewOutput

extension LoginPresenter: LoginViewOutput {
    func viewRequestedRegistration(_ login: String, _ pass: String) {
        // If there is no ID or no password, re-register.
        guard let id = auth.getId(login),
                let passKeychain = auth.getPassword(login)
        else {
            do {
                //  Create a user in the database and store their authentication details in a secure repository
                let user = UserModel()
                try realm.set(user)
                auth.setLoginPass(id: user.id.stringValue, login: login, pass: pass)
                viewInput?.showAllert("Succes", "Registration is complete")
            } catch {

            }
            return
        }

        guard passKeychain != pass else {
            viewInput?.showAllert("Succes", "Password is already registered to the user")
            return
        }
        // If the password is new, overwrite it.
        auth.setLoginPass(id: id, login: login, pass: pass)
        viewInput?.showAllert("Succes", "Password has been changed")
    }

    func viewRequestedLogin(_ login: String, _ pass: String) {
        guard let passKeychain = auth.getPassword(login) else {
            viewInput?.showAllert("Authorization error", "This user is not registered")
            return
        }

        guard passKeychain == pass, let id = auth.getId(login) else {
            viewInput?.showAllert("Authorization error", "Bad password")
            return
        }
        
        do {
            // If the password is correct, retrieve the user data and transfer the data to the new screen.
            let id = try ObjectId(string: id)
            let user = try realm.get(UserModel.self, primaryKey: id)
            coordinator.openMapScreen(user: user)
        } catch {
            // If there is an id in the secure storage but not in the database, creates a user with this id in the database.
            do {
                let id = try ObjectId(string: id)
                let user = UserModel(id: id)
                try realm.set(user)
                coordinator.openMapScreen(user: user)
            } catch {
                viewInput?.showAllert("Database error", error.localizedDescription)
            }
        }
    }
}
