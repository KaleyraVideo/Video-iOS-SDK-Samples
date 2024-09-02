// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

#if SAMPLE_CUSTOMIZABLE_THEME
extension UINavigationController: Themable {
    func themeChanged(theme: AppTheme) {
        navigationBar.barTintColor = theme.barTintColor?.toUIColor()
        let navBarTitleColor = (navigationBar.barTintColor?.isLight ?? true) ? UIColor.black : UIColor.white
        let titleColor = theme.secondaryBackgroundColor.toUIColor().isLight ? UIColor.black : UIColor.white

        var attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: navBarTitleColor]
        var largeAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: titleColor]

        if let font = theme.navBarTitleFont {
            attributes[NSAttributedString.Key.font] = font.toUIFont()
            largeAttributes[NSAttributedString.Key.font] = font.toUIFont().withSize(theme.largeFontPointSize)
        }

        navigationBar.titleTextAttributes = attributes
        navigationBar.largeTitleTextAttributes = largeAttributes

        navigationBar.barStyle = theme.barStyle
        navigationBar.isTranslucent = theme.barTranslucent
        navigationBar.tintColor = theme.accentColor.toUIColor()

        viewControllers.forEach { childViewController in
            if let themableViewController = childViewController as? Themable {
                themableViewController.themeChanged(theme: theme)
            }
        }
    }
}
#endif
