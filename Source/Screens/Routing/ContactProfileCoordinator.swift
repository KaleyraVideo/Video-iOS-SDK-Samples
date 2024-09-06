// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

final class ContactProfileCoordinator: BaseCoordinator {

    private let contact: Contact
    private let store: ContactsStore

    private(set) lazy var controller: UIViewController = {
        let navController = UINavigationController(rootViewController: profileController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    private lazy var profileController: ContactUpdateTableViewController = .init(contact: contact, store: store)

    init(contact: Contact, store: ContactsStore, services: ServicesFactory) {
        self.contact = contact
        self.store = store
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact) -> Void) {
        profileController.onDismiss = onDismiss
    }
}
