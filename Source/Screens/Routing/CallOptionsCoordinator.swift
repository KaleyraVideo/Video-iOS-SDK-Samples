// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class CallOptionsCoordinator: BaseCoordinator {

    private let appSettings: AppSettings
    private lazy var optionsController: CallOptionsTableViewController = .init(appSettings: appSettings, services: services)

    private(set) lazy var controller: UIViewController = {
        let navController = UINavigationController(rootViewController: optionsController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    init(appSettings: AppSettings, services: ServicesFactory) {
        self.appSettings = appSettings
        super.init(services: services)
    }

    func start(onDismiss: @escaping (CallOptions) -> Void) {
        optionsController.onDismiss = onDismiss
    }
}
