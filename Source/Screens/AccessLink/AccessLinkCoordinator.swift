// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class AccessLinkCoordinator: BaseCoordinator {

    var controller: UIViewController {
        accessLinkController
    }

    private lazy var accessLinkController = AccessLinkViewController()
    private let config: Config
    private let appSettings: AppSettings

    init(config: Config, appSettings: AppSettings, services: ServicesFactory) {
        self.config = config
        self.appSettings = appSettings
        super.init(services: services)
    }

    func start(onDismiss: @escaping () -> Void) {
        guard #available(iOS 15.0, *) else { onDismiss(); return }

        let coordinator = SDKCoordinator(controller: accessLinkController, config: config, book: services.makeAddressBook(config: config), appSettings: appSettings, services: services)
        addChild(coordinator)
        coordinator.start(authentication: .accessLink)
        accessLinkController.onDismiss = { [weak self] in
            self?.removeChild(coordinator)
            coordinator.stop()
            onDismiss()
        }
    }
}
