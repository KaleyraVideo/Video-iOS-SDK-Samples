// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@objc
class AppThemeColor: NSObject, Codable {

    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 1

    convenience override init() {
        self.init(from: .black)
    }

    init(from color: UIColor) {
        super.init()
        setValues(from: color)
    }

    func toUIColor() -> UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func setValues(from color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
