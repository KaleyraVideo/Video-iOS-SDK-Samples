// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class LoginCoordinator: BaseCoordinator {

    private let book: AddressBook
    private lazy var loginController: LoginViewController = .init(viewModel: .init(book: book), services: services)

    var controller: UIViewController {
        loginController
    }

    init(book: AddressBook, services: ServicesFactory) {
        self.book = book
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact?) -> Void) {
        loginController.definesPresentationContext = true
        loginController.onSelection = onDismiss
        loginController.handleErrorTapped = { onDismiss(nil) }
    }
}
