// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

struct Theme {
    struct Color {
        static let primary = UIColor(rgb: 0xD80D30)
        static var secondary = UIColor(rgb: 0xE8060A)

        static var commonBlackColor: UIColor {
            return UIColor(light: .black, dark: .white)
        }

        static var commonWhiteColor: UIColor {
            return UIColor(light: .white, dark: .black)
        }

        static var defaultButtonBackground: UIColor {
            .init(rgb: 0xE2E2E2)
        }

        static var defaultButtonTint: UIColor {
            .init(rgb: 0x1B1B1B)
        }

        static var bottomSheetBackground: UIColor {
            .init(rgb: 0xEEEEEE)
        }
    }
}
