// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIColor {

    var resolvedDark: UIColor {
        resolved(style: .dark)
    }

    var resolvedLight: UIColor {
        resolved(style: .light)
    }

    private func resolved(style: UIUserInterfaceStyle) -> UIColor {
        resolvedColor(with: .init(userInterfaceStyle: style))
    }
}
