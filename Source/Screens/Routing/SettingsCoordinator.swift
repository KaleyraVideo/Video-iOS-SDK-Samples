// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

protocol SettingsCoordinatorDelegate: AnyObject {

    func settingsCoordinatorDidLogout()
    func settingsCoordinatorDidReset()
}

final class SettingsCoordinator: BaseCoordinator, SettingsViewControllerDelegate {

    private let session: UserSession

    private lazy var settingsController: SettingsViewController = {
        let controller = SettingsViewController(session: session, services: services)
        controller.title = Strings.Settings.title
        controller.tabBarItem = .init(title: Strings.Settings.tabName, image: Icons.settings, selectedImage: nil)
        controller.tabBarItem.imageInsets = .init(top: 3, left: 0, bottom: 4, right: 3)
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

    init(session: UserSession, services: ServicesFactory, delegate: SettingsCoordinatorDelegate? = nil) {
        self.session = session
        self.delegate = delegate
        super.init(services: services)
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

        let coordinator = ContactProfileCoordinator(contact: session.user, store: services.makeContactsStore(config: session.config), services: services)
        coordinator.start(onDismiss: { [weak self] contact in
            guard let self else { return }

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
