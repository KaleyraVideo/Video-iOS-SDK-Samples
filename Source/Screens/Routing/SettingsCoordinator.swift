// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: AnyObject {

    func settingsCoordinatorDidLogout()
    func settingsCoordinatorDidReset()
    func settingsCoordinatorDidUpdateContact(contact: Contact)
}

final class SettingsCoordinator: BaseCoordinator, SettingsViewControllerDelegate {

    private let loggedUser: Contact
    private let config: Config

    private lazy var settingsController: SettingsViewController = {
        let controller = SettingsViewController(user: loggedUser, config: config, settingsStore: services.makeUserDefaultsStore())
        controller.title = Strings.Settings.title
        controller.tabBarItem = UITabBarItem(title: Strings.Settings.tabName, image: Icons.settings, selectedImage: nil)
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 0, bottom: 4, right: 3)
        controller.delegate = self

#if SAMPLE_CUSTOMIZABLE_THEME
        controller?.themeChanged(theme: settingsCoordinator.themeStorage.getSelectedTheme())
#endif
        return controller
    }()

    private(set) lazy var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }()

    weak var delegate: SettingsCoordinatorDelegate?

    private var logService: LogServiceProtocol {
        services.makeLogService()
    }

    // MARK: - Children

    private var profileCoordinator: ContactProfileCoordinator? {
        children.compactMap({ $0 as? ContactProfileCoordinator }).first
    }

    // MARK: - Init

    init(services: ServicesFactory,
         loggedUser: Contact,
         config: Config,
         delegate: SettingsCoordinatorDelegate? = nil) {
        self.loggedUser = loggedUser
        self.config = config
        self.delegate = delegate
        super.init(services: services)
    }

    func updateContact(contact: Contact) {
        settingsController.user = contact
    }

    func start() {
        if logService.areLogFilesPresent {
            settingsController.shareLogsAction = { [weak self] in
                self?.handle(event: .shareLogFiles, direction: .toParent)
            }
        }
        navigationController.setViewControllers([settingsController], animated: false)
    }

    // MARK: - Contact profile

    private func addContactProfileCoordinator() {
        guard profileCoordinator == nil else { return }

        let coordinator = ContactProfileCoordinator(contact: loggedUser, services: services)
        coordinator.start(onDismiss: { [weak self] contact in
            guard let self = self else { return }

            if contact.alias == self.loggedUser.alias {
                settingsController.user = contact
            }

            self.delegate?.settingsCoordinatorDidUpdateContact(contact: contact)

            self.removeChild(coordinator)
        })
        addChild(coordinator)
        let controller = coordinator.controller
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
        settingsController.present(controller, animated: true, completion: nil)
    }

    // MARK: - Settings View Controller delegate

    func settingsViewControllerDidLogout() {
        delegate?.settingsCoordinatorDidLogout()
    }

    func settingsViewControllerDidReset() {
        delegate?.settingsCoordinatorDidReset()
    }

    func settingsViewControllerDidUpdateUser(contact: Contact) {
        addContactProfileCoordinator()
    }

#if SAMPLE_CUSTOMIZABLE_THEME

    func openTheme() {
        let pickerFactory = PickerFactory()
        let themeCoordinator = ThemeCoordinator(navigationController: navigationController, themeStorage: servicesFactory.makeThemeStorage())
        themeCoordinator.pickerFactory = pickerFactory
        addChild(themeCoordinator)
        themeCoordinator.start()
    }

#endif

}
