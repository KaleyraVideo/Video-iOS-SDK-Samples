// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class AppSetupCoordinator: BaseCoordinator {

    enum Stage {
        case configuration
        case userSelection(config: Config)
    }

    var controller: UIViewController {
        navigationController
    }

    private lazy var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }()

    private var stage: Stage
    private let allowReconfiguration: Bool
    private let appSettings: AppSettings
    private var onDismiss: ((UserSession) -> Void)?

    init(stage: Stage, allowReconfiguration: Bool, appSettings: AppSettings, services: ServicesFactory) {
        self.stage = stage
        self.allowReconfiguration = allowReconfiguration
        self.appSettings = appSettings
        super.init(services: services)
    }

    func start(onDismiss: @escaping (UserSession) -> Void) {
        self.onDismiss = onDismiss

        switch stage {
            case .configuration:
                goToConfigurationStage(config: nil)
            case .userSelection(config: let config):
                var controllers = [UIViewController]()
                if allowReconfiguration {
                    controllers.append(setupConfigurationStage(config: config))
                }
                controllers.append(setupUserSelectionStage(config: config))
                navigationController.setViewControllers(controllers, animated: true)
        }
    }

    private func setupConfigurationStage(config: Config?) -> UIViewController {
        let coordinator = AppConfigurationCoordinator(config: config, services: services)
        addChild(coordinator)
        coordinator.start { [weak self] config in
            try? self?.services.makeSettingsRepository().store(config)
            self?.goToUserSelectionStage(config: config)
        }
        let controller = coordinator.controller
        controller.navigationItem.rightBarButtonItem = .qrButton(target: self, action: #selector(qrScanButtonTapped))
        controller.navigationItem.largeTitleDisplayMode = .always
        return controller
    }

    private func setupUserSelectionStage(config: Config) -> UIViewController {
        let addressBook = services.makeAddressBook(config: config)
        let coordinator = LoginCoordinator(book: addressBook, services: services)
        addChild(coordinator)
        coordinator.start { [weak self, weak coordinator] user in
            guard let self else { return }
            guard let coordinator else { return }

            self.removeChild(coordinator)

            guard let user else { return }

            self.onDismiss?(.init(config: config, user: user, addressBook: addressBook, services: services))
        }
        let controller = coordinator.controller
        controller.navigationItem.rightBarButtonItem = .accessLinkButton(action: { [weak self] in
            self?.goToAccessLink(config: config)
        })
        return controller
    }

    @objc
    private func qrScanButtonTapped() {
        let controller = QRReaderViewController()
        controller.onDismiss = { [weak self] qr in
            guard let self else { return }

            self.navigationController.popViewController(animated: true)

            guard let qr else { return }

            self.goToUserSelectionStage(config: qr.config)
        }

        controller.navigationItem.hidesBackButton = true

        navigationController.pushViewController(controller, animated: true)
    }

    private func goToAccessLink(config: Config) {
        let coordinator = AccessLinkCoordinator(config: config, appSettings: appSettings, services: services)
        addChild(coordinator)
        coordinator.start { [weak self, weak coordinator] in
            guard let self else { return }
            guard let coordinator else { return }

            self.removeChild(coordinator)
        }
        let controller = coordinator.controller
        controller.navigationItem.title = Strings.AccessLink.title
        navigationController.pushViewController(controller, animated: true)
    }

    private func goToConfigurationStage(config: Config?) {
        stage = .configuration
        navigationController.setViewControllers([setupConfigurationStage(config: config)], animated: true)
    }

    private func goToUserSelectionStage(config: Config) {
        stage = .userSelection(config: config)
        navigationController.pushViewController(setupUserSelectionStage(config: config), animated: true)
    }
}

private extension UIBarButtonItem {

    static func qrButton(target: Any, action: Selector) -> UIBarButtonItem {
        .init(image: Icons.qrCode, style: .plain, target: target, action: action)
    }

    static func accessLinkButton(action: @escaping () -> Void) -> UIBarButtonItem {
        .init(image: Icons.link, style: .plain, action: action)
    }
}
