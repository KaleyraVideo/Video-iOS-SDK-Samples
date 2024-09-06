// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

final class MainCoordinator: BaseCoordinator {

    private let session: UserSession
    private let appSettings: AppSettings

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

    init(session: UserSession, appSettings: AppSettings, services: ServicesFactory) {
        self.session = session
        self.appSettings = appSettings
        super.init(services: services)

        addChildren()
    }

    private func addChildren() {
        addSDKCoordinator()
        addContactsCoordinator()
        addSettingsCoordinator()
    }

    private func addSDKCoordinator() {
        addChild(SDKCoordinator(controller: tabBarController, config: session.config, appSettings: appSettings, services: services, delegate: self))
    }

    private func addContactsCoordinator() {
        addChild(ContactsCoordinator(session: session, appSettings: appSettings, services: services))
    }

    private func addSettingsCoordinator() {
        addChild(SettingsCoordinator(session: session, services: services, delegate: self))
    }

    // MARK: - Start

    func start() {
        contactsCoordinator.start(onActionSelected: ({ [weak self] action in
            guard let self else { return }

            self.handle(event: action.coordinatorEvent, direction: .toChildren)
        }))
        settingsCoordinator.start()
        sdkCoordinator.start(authentication: .accessToken(userId: session.user.alias))
        tabBarController.setViewControllers([contactsCoordinator.navigationController, settingsCoordinator.navigationController], animated: true)
    }
}

extension MainCoordinator: SDKCoordinatorDelegate {

    func sdkIsLoading(_ isLoading: Bool) {
//        contactsCoordinator.onChangeState(isLoading: isLoading)
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
