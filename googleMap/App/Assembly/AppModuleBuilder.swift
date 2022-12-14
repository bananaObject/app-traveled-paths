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

    static func appBuild() -> UIViewController {
        let realm = RealmService()
        let presenter = MapPresenter(realm)
        let viewController = MapViewController(presenter)
        presenter.viewInput = viewController

        return viewController
    }
}
