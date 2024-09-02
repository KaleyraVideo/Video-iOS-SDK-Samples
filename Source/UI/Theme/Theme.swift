// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

struct Theme {
    struct Color {
        static let primary = UIColor(rgb: 0xD80D30)
        static var secondary = UIColor(rgb: 0xE8060A)

        static let selectedTintTabBar = UIColor.rgba(red: 15, green: 41, blue: 124, alpha: 1)
        static let unselectedTintTabBar = UIColor.rgba(red: 117, green: 117, blue: 117, alpha: 1)

        static var labelSettingItem: UIColor {
            return UIColor.dynamicColor(light: UIColor.rgba(red: 96, green: 96, blue: 96, alpha: 1), dark: .white)
        }

        static var commonBlackColor: UIColor {
            return UIColor.dynamicColor(light: .black, dark: .white)
        }

        static var commonWhiteColor: UIColor {
            return UIColor.dynamicColor(light: .white, dark: .black)
        }
    }
}
