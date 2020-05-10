//
// Created by Luca Tagliabue on 2019-09-30.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import UIKit

//Here we subclass UINavigationController class in order to change preferredStatusBarStyle when the CallBannerView is showed.

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

    func setStatusBarAppearance(_ style: UIStatusBarStyle) {
        if statusBarStyleBackup == nil {
            statusBarStyleBackup = preferredStatusBarStyle
        }
        statusBarStyle = style
    }

    func restoreStatusBarAppearance() {
        statusBarStyle = statusBarStyleBackup
    }
}
