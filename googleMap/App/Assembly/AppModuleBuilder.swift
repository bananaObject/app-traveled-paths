//
//  AppModuleBuilder.swift
//  googleMap
//
//  Created by Ke4a on 09.12.2022.
//

import Foundation
import UIKit

/// Controller builder.
final class AppModuleBuilder {
    // MARK: - Static Methods

    static func startScreen(coordinator: Coordinator) -> UIViewController {
        return loginScreen(coordinator: coordinator)
    }

    static func mapScreen(user: UserModel, coordinator: Coordinator) -> UIViewController {
        let realm = RealmService()
        let presenter = MapPresenter(realm, user: user)
        let viewController = MapViewController(presenter)
        presenter.viewInput = viewController

        return viewController
    }

    static func loginScreen(coordinator: Coordinator) -> UIViewController {
        let realm = RealmService()
        let auth = AuthService()
        let presenter = LoginPresenter(realm, auth, coordinator)
        let viewController = LoginViewController(presenter: presenter)
        presenter.viewInput = viewController

        return viewController
    }
}
