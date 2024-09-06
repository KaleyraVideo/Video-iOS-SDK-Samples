// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

extension UIViewController {

    public func presentAlert(_ alert: UIAlertController, animated: Bool = true, completion: (() -> Void)? = nil) {
        assert(alert.preferredStyle == .alert, "Trying to present an action sheet as an alert")
        present(alert, animated: animated, completion: completion)
    }
}
