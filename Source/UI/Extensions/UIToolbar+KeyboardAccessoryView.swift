// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIToolbar {

    static func createWithRightAlignedDismissButton(title: String, target: AnyObject, action: Selector) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: Strings.Setup.confirm, style: .plain, target: target, action: action)
        ]
        toolbar.sizeToFit()

        return toolbar
    }
}
