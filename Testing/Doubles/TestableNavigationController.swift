// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class TestableNavigationController: UINavigationController {

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: false)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: false)
    }

    override func show(_ vc: UIViewController, sender: Any?) {
        super.pushViewController(vc, animated: false)
    }
}
