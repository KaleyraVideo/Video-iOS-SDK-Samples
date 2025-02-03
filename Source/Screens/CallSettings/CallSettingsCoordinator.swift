// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class CallSettingsCoordinator: BaseCoordinator {

    private let appSettings: AppSettings
    private lazy var settingsController: CallSettingsViewController = .init(appSettings: appSettings, services: services)

    @available(iOS 15.0, *)
    private var bottomSheetController: UIViewController {
        let controller = BottomSheetViewController()
        controller.addButtonAction = { [weak self] in
            self?.controller.pushViewController(EditButtonViewController(), animated: true)
        }
        return controller
    }

    private(set) lazy var controller: UINavigationController = {
        let controller = if #available(iOS 15.0, *) {
            bottomSheetController
        } else {
            settingsController
        }
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    init(appSettings: AppSettings, services: ServicesFactory) {
        self.appSettings = appSettings
        super.init(services: services)
    }

    func start(onDismiss: @escaping () -> Void) {
        settingsController.onDismiss = onDismiss
    }
}
