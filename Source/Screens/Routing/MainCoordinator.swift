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

    @available(iOS 15.0, *)
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
        guard #available(iOS 15.0, *) else { return }
        addChild(SDKCoordinator(controller: tabBarController, config: session.config, appSettings: appSettings, services: services))
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

        if #available(iOS 15.0, *) {
            sdkCoordinator.start(authentication: .accessToken(userId: session.user.alias))
        }
        tabBarController.setViewControllers([contactsCoordinator.navigationController, settingsCoordinator.navigationController], animated: true)
    }
}

extension MainCoordinator: SettingsCoordinatorDelegate {

    func settingsCoordinatorDidReset() {
        if #available(iOS 15.0, *) {
            sdkCoordinator.reset()
        }
        onReset?()
    }

    func settingsCoordinatorDidLogout() {
        if #available(iOS 15.0, *) {
            sdkCoordinator.stop()
        }
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
