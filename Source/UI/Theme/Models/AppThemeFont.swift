// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@objc
class AppThemeFont: NSObject, Codable {

    var fontName: String = ""
    var pointSize: CGFloat = 0

    override init() {
        super.init()
    }

    init(from font: UIFont) {
        super.init()
        setValues(from: font)
    }

    func toUIFont() -> UIFont {
        let pointSize = pointSize >= 0 ? pointSize : UIFont.systemFontSize

        guard let font = UIFont(name: fontName, size: pointSize) else {
            return UIFont.systemFont(ofSize: pointSize)
        }

        return font
    }

    func setValues(from font: UIFont) {
        fontName = font.fontName
        pointSize = font.pointSize
    }
}
