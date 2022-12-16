//
//  MapCoordinating.swift
//  googleMap
//
//  Created by Ke4a on 14.12.2022.
//

import Foundation

final class MapCoordinating: Coordinating {
    private var applicationCoordinator: Coordinator
    private let user: UserModel

    init(_ appCordinator: Coordinator, user: UserModel) {
        self.applicationCoordinator = appCordinator
        self.user = user
    }

    func start() {
        let controller = AppModuleBuilder.mapScreen(user: user, coordinator: applicationCoordinator)
        controller.modalPresentationStyle = .fullScreen
        applicationCoordinator.presentController(controller)
    }
}
