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
    var appearance: Appearance?
    var action: Action?
}

extension CustomButton {

    struct Appearance {
        var tintColor: UIColor?
        var backgroundColor: UIColor?
    }

    enum Action {
        case openMaps
        case openURL
    }
}
