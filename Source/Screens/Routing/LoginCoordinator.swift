// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class LoginCoordinator: BaseCoordinator {

    private let config: Config
    private lazy var viewModel: ContactsViewModel = .init(store: services.makeContactsStore(config: config))
    private lazy var loginController: LoginViewController = LoginViewController(viewModel: viewModel, services: services)

    var controller: UIViewController {
        loginController
    }

    init(config: Config, services: ServicesFactory) {
        self.config = config
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact?) -> Void) {
        loginController.definesPresentationContext = true
        loginController.onSelection = onDismiss
        loginController.handleErrorTapped = { onDismiss(nil) }
    }
}
