// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class ContactsCoordinator: BaseCoordinator {

    private let session: UserSession
    private let appSettings: AppSettings
    private lazy var viewModel: ContactsViewModel = .init(book: session.addressBook, loggedUser: session.user)

    private(set) lazy var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.navigationBar.prefersLargeTitles = true
        controller.navigationBar.tintColor = Theme.Color.secondary
        controller.definesPresentationContext = true
        return controller
    }()

    private var contactController: ContactsViewController!

    init(session: UserSession, appSettings: AppSettings, services: ServicesFactory) {
        self.session = session
        self.appSettings = appSettings
        super.init(services: services)
    }

    func start(onActionSelected: @escaping (ContactsViewController.Action) -> Void) {
        contactController = makeContactsViewController(onActionSelected: onActionSelected)
        navigationController.setViewControllers([contactController], animated: false)
    }

    private func makeContactsViewController(onActionSelected: @escaping (ContactsViewController.Action) -> Void) -> ContactsViewController {
        let controller = ContactsViewController(appSettings: appSettings, viewModel: viewModel, services: services)
        controller.tabBarItem = .init(title: Strings.Contacts.tabName, image: Icons.contact, selectedImage: nil)
        controller.definesPresentationContext = true
        controller.onContactProfileSelected = { [weak self] contact in
            self?.showProfileScreen(contact)
        }
        controller.onActionSelected = onActionSelected
        controller.onCallSettingsSelected = { [weak self] in
            self?.showCallSettingsScreen()
        }
        return controller
    }

    private func showProfileScreen(_ contact: Contact) {
        let coordinator = ContactProfileCoordinator(contact: contact, book: session.addressBook, services: services)
        coordinator.start(onDismiss: { [weak self] _ in
            guard let self else { return }

            self.removeChild(coordinator)
        })
        addChild(coordinator)
        let controller = coordinator.controller
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
        contactController.present(controller, animated: true)
    }

    private func showCallSettingsScreen() {
        let coordinator = CallSettingsCoordinator(appSettings: appSettings, services: services)
        addChild(coordinator)
        coordinator.start(onDismiss: { [weak self] in
            self?.removeChild(coordinator)
        })
        let controller = coordinator.controller
        controller.modalPresentationStyle = .pageSheet
        contactController.present(controller, animated: true)
    }
}
