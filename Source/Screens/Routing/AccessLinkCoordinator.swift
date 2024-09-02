// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class AccessLinkCoordinator: BaseCoordinator {

    var controller: UIViewController {
        accessLinkController
    }

    private let accessLinkController = AccessLinkViewController()
    private let config: Config

    init(config: Config, services: ServicesFactory) {
        self.config = config
        super.init(services: services)
    }

    func start(onDismiss: @escaping () -> Void) {
        let coordinator = SDKCoordinator(currentController: accessLinkController,
                                         config: config,
                                         services: services)
        addChild(coordinator)
        coordinator.start(authentication: .accessLink)
        accessLinkController.onDismiss = { [weak self] in
            self?.removeChild(coordinator)
            coordinator.stop()
            onDismiss()
        }
    }
}
