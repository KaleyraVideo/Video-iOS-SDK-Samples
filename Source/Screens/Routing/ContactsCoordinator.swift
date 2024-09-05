// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class ContactsCoordinator: BaseCoordinator {

    private let config: Config
    private let loggedUser: Contact
    private lazy var viewModel: ContactsViewModel = .init(store: services.makeContactsStore(config: config), loggedUser: loggedUser.alias)
    private var onCallOptionsChanged: ((CallOptions) -> Void)?
    private var isMultipleSelectionEnabled: Bool

    private(set) lazy var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.navigationBar.prefersLargeTitles = true
        controller.navigationBar.tintColor = Theme.Color.secondary
        controller.definesPresentationContext = true
        return controller
    }()

    private var contactController: ContactsViewController!

    init(config: Config, loggedUser: Contact, services: ServicesFactory) {
        self.config = config
        self.loggedUser = loggedUser
        self.isMultipleSelectionEnabled = services.makeUserDefaultsStore().getCallOptions().isGroup
        super.init(services: services)
    }

    func start(onCallOptionsChanged: @escaping (CallOptions) -> Void,
               onActionSelected: @escaping (ContactsViewController.Action) -> Void) {
        contactController = makeContactsViewController(onActionSelected: onActionSelected)
        updateMultipleSelection(enabled: isMultipleSelectionEnabled, animated: false)
        self.onCallOptionsChanged = onCallOptionsChanged
        navigationController.setViewControllers([contactController], animated: false)
    }

    private func makeContactsViewController(onActionSelected: @escaping (ContactsViewController.Action) -> Void) -> ContactsViewController {
        let controller = ContactsViewController(viewModel: viewModel, services: services)
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
        let coordinator = ContactProfileCoordinator(contact: loggedUser, services: services, config: config)
        coordinator.start(onDismiss: { [weak self] contact in
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
        let coordinator = CallOptionsCoordinator(services: services)
        addChild(coordinator)
        coordinator.start(onDismiss: { [weak self] options in
            self?.removeChild(coordinator)
            self?.updateMultipleSelection(enabled: options.isGroup)
            self?.onCallOptionsChanged?(options)
        })
        let controller = coordinator.controller
        controller.modalPresentationStyle = .pageSheet
        contactController.present(controller, animated: true)
    }

    func onChangeState(isLoading: Bool) {
        if isLoading {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            contactController?.navigationItem.setRightBarButton(.init(customView: activityIndicator), animated: true)
        } else {
        }
    }

    private func updateMultipleSelection(enabled: Bool, animated: Bool = true) {
        isMultipleSelectionEnabled = enabled
        if enabled {
            contactController.enableMultipleSelection(animated: animated)
        } else {
            contactController.disableMultipleSelection(animated: animated)
        }
    }
}
