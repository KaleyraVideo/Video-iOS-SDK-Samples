// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

#if SAMPLE_CUSTOMIZABLE_THEME
extension UITabBarController: Themable {
    func themeChanged(theme: AppTheme) {
        let app = tabBar.standardAppearance
        app.backgroundColor = theme.barTintColor?.toUIColor()
        app.selectionIndicatorTintColor = theme.barTintColor?.toUIColor()
        tabBar.standardAppearance = app
        tabBar.isTranslucent = theme.barTranslucent

        viewControllers?.forEach { childViewController in
            if let themableViewController = childViewController as? Themable {
                themableViewController.themeChanged(theme: theme)
            }
        }
    }
}
#endif
