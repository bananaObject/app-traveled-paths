//
//  LoginCoordinator.swift
//  googleMap
//
//  Created by Ke4a on 14.12.2022.
//

import Foundation

final class LoginCoordinating: Coordinating {
    private var applicationCoordinator: Coordinator

    init(_ appCordinator: Coordinator) {
        self.applicationCoordinator = appCordinator
    }

    func start() {
        let controller = AppModuleBuilder.loginScreen(coordinator: applicationCoordinator)
        controller.modalPresentationStyle = .fullScreen
        applicationCoordinator.presentController(controller)
    }
}
