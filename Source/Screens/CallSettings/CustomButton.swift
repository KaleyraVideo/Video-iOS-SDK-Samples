// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

struct CustomButton {

    var title: String?
    var icon: UIImage?
    var isEnabled: Bool = true
    var accessibilityLabel: String?
    var badge: UInt?
    var tint: UIColor?
    var background: UIColor?
    var action: Action?
}

extension CustomButton {

    enum Action {
        case openMaps
        case openURL
    }
}
