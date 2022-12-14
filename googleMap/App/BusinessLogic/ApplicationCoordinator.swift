//
//  ApplicationCoordinator.swift
//  googleMap
//
//  Created by Ke4a on 14.12.2022.
//

import UIKit

protocol Coordinator {
    /// Shows the selected controller without storing the previous one in memory.
    /// - Parameter controller: Controller.
    func presentController(_ controller: UIViewController)
    /// Show controller with the option to revert to the old one.
    /// - Parameter controller: Controller.
    func navigationPushController(_ controller: UIViewController)
    /// Opens map screen.
    /// - Parameter user: Information about the user whose details will be displayed on the map.
    func openMapScreen(user: UserModel)
}

protocol Coordinating {
    /// Start the display of the controller on the screen.
    func start()
}

final class ApplicationCoordinator {
    // MARK: - Private Properties
    
    private lazy var navController: UINavigationController = {
        let nav = UINavigationController()
        nav.view.backgroundColor = .white
        return nav
    }()
    private weak var controller: UIViewController?

    private var coordinating: Coordinating? {
        didSet {
            coordinating?.start()
        }
    }

    // MARK: - Initialization

    init(window: UIWindow?) {
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }

    // MARK: - Public Methods

    /// Start of the coordinator.
    func start() {
        let coordinating = LoginCoordinating(self)
        coordinating.start()
    }

    // MARK: - Private Methods

    /// Start of the coordinator.
    /// - Parameter coordinating: Coordinating.
    private func newCoordinating(_ coordinating: Coordinating) {
        self.coordinating = coordinating
    }
}

// MARK: - Coordinator

extension ApplicationCoordinator: Coordinator {

    func presentController(_ controller: UIViewController) {
        let isAnimation = self.controller != nil

        self.navController.setViewControllers([controller], animated: isAnimation)
        self.controller = controller
    }

    func navigationPushController(_ controller: UIViewController) {
        navController.pushViewController(controller, animated: true)
        self.controller = controller
    }

    func openMapScreen(user: UserModel) {
        let coordinating = MapCoordinating(self, user: user)
        newCoordinating(coordinating)
    }
}
