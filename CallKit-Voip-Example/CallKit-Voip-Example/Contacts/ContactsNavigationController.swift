//
// Created by Luca Tagliabue on 2019-10-01.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

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
