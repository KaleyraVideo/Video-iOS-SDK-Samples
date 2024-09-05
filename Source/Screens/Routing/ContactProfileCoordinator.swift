// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

final class ContactProfileCoordinator: BaseCoordinator {

    private let contact: Contact
    private let config: Config

    private(set) lazy var controller: UIViewController = {
        let navController = UINavigationController(rootViewController: profileController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    private lazy var profileController: ContactUpdateTableViewController = .init(contact: contact, store: services.makeContactsStore(config: config))

    init(contact: Contact, services: ServicesFactory, config: Config) {
        self.contact = contact
        self.config = config
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact) -> Void) {
        profileController.onDismiss = onDismiss
    }
}
