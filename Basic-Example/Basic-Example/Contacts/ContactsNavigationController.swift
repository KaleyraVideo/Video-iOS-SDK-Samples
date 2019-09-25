// Copyright © 2019 Bandyer. All rights reserved.
// See LICENSE for licensing information

import UIKit

class ContactsNavigationController: UINavigationController {

    private var statusBarStyleBackup: UIStatusBarStyle?

    private var statusBarStyle: UIStatusBarStyle? {
        didSet {
            guard statusBarStyle != nil else { return }

            guard statusBarStyle != oldValue else { return }

            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {

        guard let style = statusBarStyle else { return super.preferredStatusBarStyle }

        return style
    }

    @objc public func setStatusBarAppearance(_ style: UIStatusBarStyle) {
        if statusBarStyleBackup == nil {
            statusBarStyleBackup = preferredStatusBarStyle
        }
        statusBarStyle = style
    }

    @objc public func restoreStatusBarAppearance() {
        statusBarStyle = statusBarStyleBackup
    }
}
