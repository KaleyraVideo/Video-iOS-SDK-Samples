// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

final class ContactProfileCoordinator: BaseCoordinator {

    private let contact: Contact
    private let book: AddressBook

    private(set) lazy var controller: UIViewController = {
        let navController = UINavigationController(rootViewController: profileController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    private lazy var profileController: ContactProfileViewController = .init(contact: contact, book: book)

    init(contact: Contact, book: AddressBook, services: ServicesFactory) {
        self.contact = contact
        self.book = book
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact) -> Void) {
        profileController.onDismiss = onDismiss
    }
}
