// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

final class MainCoordinator: BaseCoordinator {

    private let config: Config
    private let loggedUser: Contact

    // MARK: - View Controllers

    private(set) lazy var tabBarController: UITabBarController = {
        let controller = UITabBarController()
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        controller.tabBar.standardAppearance = appearance
        return controller
    }()

    // MARK: - Children

    var sdkCoordinator: SDKCoordinator! {
        children.compactMap({ $0 as? SDKCoordinator }).first
    }

    var contactsCoordinator: ContactsCoordinator! {
        children.compactMap({ $0 as? ContactsCoordinator }).first
    }

    var settingsCoordinator: SettingsCoordinator! {
        children.compactMap({ $0 as? SettingsCoordinator }).first
    }

    // MARK: - Events

    var onLogout: (() -> Void)?
    var onReset: (() -> Void)?
    var onError: (() -> Void)?
    var onUpdateContact: ((Contact) -> Void)?

    init(config: Config, loggedUser: Contact, services: ServicesFactory) {
        self.config = config
        self.loggedUser = loggedUser

        super.init(services: services)

        addChildren()
    }

    private func addChildren() {
        addBandyerCoordinator()
        addContactsCoordinator()
        addSettingsCoordinator()
    }

    private func addBandyerCoordinator() {
        addChild(SDKCoordinator(controller: tabBarController, config: config, services: services, delegate: self))
    }

    private func addContactsCoordinator() {
        addChild(ContactsCoordinator(config: config, loggedUser: loggedUser, services: services))
    }

    private func addSettingsCoordinator() {
        addChild(SettingsCoordinator(services: services, loggedUser: loggedUser, config: config, delegate: self))
    }

    // MARK: - Start

    func start() {
        contactsCoordinator.start(onCallOptionsChanged: ({ [weak self] options in
            guard let self = self else { return }

            self.sdkCoordinator.callOptions = options
        }),
                                  onUpdateContact:({ [weak self] in self?.settingsCoordinator.updateContact(contact: $0) }),
                                  onCallUser: ({ [weak self] action in
            guard let self = self else { return }

            self.handle(event: action.coordinatorEvent, direction: .toChildren)
        }))
        settingsCoordinator.start()
        sdkCoordinator.start(authentication: .accessToken(userId: loggedUser.alias))
        tabBarController.setViewControllers([contactsCoordinator.navigationController, settingsCoordinator.navigationController], animated: true)
    }
}

extension MainCoordinator: SDKCoordinatorDelegate {

    func sdkIsLoading(_ isLoading: Bool) {
        contactsCoordinator.onChangeState(isLoading: isLoading)
    }

    func sdkDidFinish(withError: Error) {
        onError?()
    }
}

extension MainCoordinator: SettingsCoordinatorDelegate {

    func settingsCoordinatorDidReset() {
        sdkCoordinator.reset()
        onReset?()
    }

    func settingsCoordinatorDidLogout() {
        sdkCoordinator.stop()
        onLogout?()
    }

    func settingsCoordinatorDidUpdateContact(contact: Contact) {
        contactsCoordinator.updateContact(contact: contact)
    }
}

private extension ContactsViewController.Action {

    var coordinatorEvent: CoordinatorEvent {
        switch self {
            case .startCall(type: let type, callees: let callees):
                .startOutgoingCall(type: type, callees: callees)
            case .openChat(user: let user):
                .openChat(userId: user)
        }
    }
}
