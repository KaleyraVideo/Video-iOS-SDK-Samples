// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class CallSettingsCoordinator: BaseCoordinator {

    private let appSettings: AppSettings

    private(set) lazy var controller: UINavigationController = {
        let navController = UINavigationController(rootViewController: settingsController)
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }()

    private lazy var settingsController: CallSettingsViewController = {
        let controller = CallSettingsViewController(appSettings: appSettings, services: services)

        if #available(iOS 15.0, *) {
            controller.onEditButtons = { [weak self] in
                self?.presentEditBottomSheetController()
            }
        }

        return controller
    }()

    @available(iOS 15.0, *)
    private var bottomSheetController: UIViewController {
        let controller = BottomSheetViewController(settings: appSettings, services: services)
        controller.onEditButtonAction = { [weak self] button in
            self?.presentEditButtonController(button)
        }
        return controller
    }

    init(appSettings: AppSettings, services: ServicesFactory) {
        self.appSettings = appSettings
        super.init(services: services)
    }

    func start(onDismiss: @escaping () -> Void) {
        settingsController.onDismiss = onDismiss
    }

    @available(iOS 15.0, *)
    private func presentEditBottomSheetController(animated: Bool = true) {
        controller.pushViewController(bottomSheetController, animated: animated)
    }

    @available(iOS 15.0, *)
    private func presentEditButtonController(_ button: Button.Custom, animated: Bool = true) {
        controller.pushViewController(EditButtonViewController(settings: appSettings, services: services, button: button), animated: animated)
    }
}
