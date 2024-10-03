// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

extension UIColor {

    // swiftlint:disable identifier_name
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        return (r: r, g: g, b: b, a: a)
    }

    var resolvedLight: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .light))
    }

    var resolvedDark: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .dark))
    }

    convenience init(light: @autoclosure @escaping () -> UIColor, dark: @autoclosure @escaping () -> UIColor) {
        self.init {
            if $0.userInterfaceStyle == .light {
                return light()
            } else {
                return dark()
            }
        }
    }

    convenience init(r: UInt8, g: UInt8, b: UInt8) {
        let max = CGFloat(UInt8.max)
        self.init(red: CGFloat(r) / max, green: CGFloat(g) / max, blue: CGFloat(b) / max, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        let red = UInt8((rgb >> 16) & 0xFF)
        let green = UInt8((rgb >> 8) & 0xFF)
        let blue = UInt8(rgb & 0xFF)
        self.init(r: red, g: green, b: blue)
    }

    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
