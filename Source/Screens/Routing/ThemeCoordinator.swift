// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ThemeCoordinator: BaseCoordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController, services: ServicesFactory) {
        self.navigationController = navigationController
        super.init(services: services)
    }

    func start() {
        navigationController.pushViewController(ThemeViewController(), animated: true)
    }
}
