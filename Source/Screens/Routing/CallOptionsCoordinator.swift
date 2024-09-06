// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class CallOptionsCoordinator: BaseCoordinator {

    private let options: CallOptions

    private lazy var optionsController: CallOptionsTableViewController = .init(options: options, services: services)

    private(set) lazy var controller: UIViewController = {
        let navController = UINavigationController(rootViewController: optionsController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    override init(services: ServicesFactory) {
        let store = services.makeUserDefaultsStore()
        self.options = store.getCallOptions()
        super.init(services: services)
    }

    func start(onDismiss: @escaping (CallOptions) -> Void) {
        optionsController.onDismiss = onDismiss
    }
}
