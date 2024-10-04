// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class LoginCoordinator: BaseCoordinator {

    private let store: ContactsStore
    private lazy var loginController: LoginViewController = .init(viewModel: .init(store: store), services: services)

    var controller: UIViewController {
        loginController
    }

    init(store: ContactsStore, services: ServicesFactory) {
        self.store = store
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact?) -> Void) {
        loginController.definesPresentationContext = true
        loginController.onSelection = onDismiss
        loginController.handleErrorTapped = { onDismiss(nil) }
    }
}
