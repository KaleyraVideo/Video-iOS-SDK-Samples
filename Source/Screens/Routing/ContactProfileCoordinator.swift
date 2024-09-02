// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

final class ContactProfileCoordinator: BaseCoordinator {

    private let contact: Contact

    private(set) lazy var controller: UIViewController = {
        let navController = UINavigationController(rootViewController: profileController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    private lazy var profileController: ContactUpdateTableViewController = .init(contact: contact, services: services) 

    init(contact: Contact, services: ServicesFactory) {
        self.contact = contact
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact) -> Void) {
        profileController.onDismiss = onDismiss
    }
}
