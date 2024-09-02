// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class AppConfigurationCoordinator: BaseCoordinator {

    private let config: Config?
    private var setupController: AppSetupViewController!

    var controller: UIViewController {
        setupController
    }

    init(config: Config?, services: ServicesFactory) {
        self.config = config
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Config) -> Void) {
        setupController = .init(model: AppSetupViewModel(config: config), services: services)
        setupController.onDismiss = onDismiss
    }
}
