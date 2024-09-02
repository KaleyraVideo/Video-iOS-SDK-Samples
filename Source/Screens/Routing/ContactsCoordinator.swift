// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class ContactsCoordinator: BaseCoordinator {

    private let config: Config
    private let loggedUser: Contact
    private var presentationAdapter: ContactsLoaderPresentationAdapter?
    private var selectedContactsAlias = [String]()
    private var onCall: ((ContactsViewController.Action) -> Void)?
    private var onCallOptionsChanged: ((CallOptions) -> Void)?
    private var onUpdateContact: ((Contact) -> Void)?
    private var isMultipleSelectionEnabled: Bool

    private lazy var settingButton: UIBarButtonItem = {
        .init(image: Icons.settings, style: .plain, target: self, action: #selector(settingButtonTapped))
    }()

    private lazy var callButton: UIBarButtonItem = {
        .init(image: Icons.phone, style: .plain, target: self, action: #selector(callButtonTapped))
    }()

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
               onUpdateContact: @escaping (Contact) -> Void,
               onCallUser: @escaping (ContactsViewController.Action) -> Void) {
        let searchController = makeSearchController()
        contactController = makeContactsViewController(searchController: searchController)
        setupContactsViewController(searchController: searchController, onUpdateContact: onUpdateContact, onCallUser: onCallUser)
        updateMultipleSelection(enabled: isMultipleSelectionEnabled, animated: false)
        self.onCall = onCallUser
        self.onCallOptionsChanged = onCallOptionsChanged
        self.onUpdateContact = onUpdateContact
        navigationController.setViewControllers([contactController], animated: false)
    }

    private func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Strings.Contacts.searchPlaceholder
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .default
        return searchController
    }

    func updateContact(contact: Contact) {
        guard let presentationAdapter = presentationAdapter else { return }

        presentationAdapter.update(contact: contact)
    }

    private func makeContactsViewController(searchController: UISearchController) -> ContactsViewController {
        let controller = ContactsViewController(services: services)
        controller.navigationItem.searchController = searchController
        controller.navigationItem.hidesSearchBarWhenScrolling = false
        controller.tabBarItem = UITabBarItem(title: Strings.Contacts.tabName, image: Icons.contact, selectedImage: nil)
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 0, bottom: 4, right: 3)
        controller.definesPresentationContext = true
        return controller
    }

    private func setupContactsViewController(searchController: UISearchController,
                                             onUpdateContact: @escaping (Contact) -> Void,
                                             onCallUser: @escaping (ContactsViewController.Action) -> Void) {
        let presentationAdapter = ContactsLoaderPresentationAdapter(presenter: ContactsPresenter(output: Weak(object: contactController)),
                                                                    store: services.makeContactsStore(config: config),
                                                                    loggedUserAlias: loggedUser.alias)
        contactController.onReady = presentationAdapter.fetchUsers
        contactController.onUpdateContact = { [weak self] contact in
            self?.showProfileUpdate(contact)
        }

        contactController.onAction = { [weak searchController] action in
            searchController?.searchBar.resignFirstResponder()
            onCallUser(action)
        }

        contactController.onUpdateSelectedContacts = { [weak self] aliases in
            guard let self = self else { return }
            self.selectedContactsAlias = aliases
            self.callButton.isEnabled = aliases.count > 0 ? true : false
        }
        self.presentationAdapter = presentationAdapter
    }

    private func showProfileUpdate(_ contact: Contact) {
        let coordinator = ContactProfileCoordinator(contact: loggedUser, services: services)
        coordinator.start(onDismiss: { [weak self] contact in
            guard let self = self else { return }

            self.updateContact(contact: contact)
            self.onUpdateContact?(contact)
            self.removeChild(coordinator)
        })
        addChild(coordinator)
        let controller = coordinator.controller
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
        contactController.present(controller, animated: true, completion: nil)
    }

    @objc
    private func callButtonTapped() {
        guard !selectedContactsAlias.isEmpty else { return }

        onCall?(.startCall(type: nil, callees: selectedContactsAlias))
    }

    @objc
    private func settingButtonTapped() {
        let coordinator = CallOptionsCoordinator(services: services)
        addChild(coordinator)
        coordinator.start(onDismiss: { [weak self] options in
            self?.removeChild(coordinator)
            self?.updateMultipleSelection(enabled: options.isGroup)
            self?.onCallOptionsChanged?(options)
        })
        let controller = coordinator.controller
        controller.modalPresentationStyle = .pageSheet
        contactController.present(controller, animated: true, completion: nil)
    }

    func onChangeState(isLoading: Bool) {
        if isLoading {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            contactController?.navigationItem.setRightBarButton(.init(customView: activityIndicator), animated: true)
        } else {
            updateNavigationBarButtons(animated: true)
        }
    }

    private func updateMultipleSelection(enabled: Bool, animated: Bool = true) {
        isMultipleSelectionEnabled = enabled
        if enabled {
            contactController.enableMultipleSelection(animated)
        } else {
            contactController.disableMultipleSelection(animated)
            selectedContactsAlias.removeAll()
        }

        updateNavigationBarButtons(animated: animated)
    }

    private func updateNavigationBarButtons(animated: Bool) {
        if isMultipleSelectionEnabled {
            contactController.navigationItem.setRightBarButtonItems([callButton, settingButton], animated: animated)
        } else {
            contactController.navigationItem.setRightBarButtonItems([settingButton], animated: animated)
        }
    }
}

extension ContactsCoordinator: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presentationAdapter?.filter(searchFilter: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presentationAdapter?.filter(searchFilter: "")
    }
}
