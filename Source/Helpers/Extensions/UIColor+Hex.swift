// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIColor {

    convenience init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = .max) {
        let max = CGFloat(UInt8.max)
        self.init(red: CGFloat(r) / max, green: CGFloat(g) / max, blue: CGFloat(b) / max, alpha: CGFloat(a) / max)
    }

    convenience init(rgb: UInt) {
        self.init(argb: (0xFF << 24) + rgb)
    }

    convenience init(argb: UInt) {
        let red = UInt8((argb >> 16) & 0xFF)
        let green = UInt8((argb >> 8) & 0xFF)
        let blue = UInt8(argb & 0xFF)
        let alpha = UInt8(argb >> 24 & 0xFF)
        self.init(r: red, g: green, b: blue, a: alpha)
    }
}
