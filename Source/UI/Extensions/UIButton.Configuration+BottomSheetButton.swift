// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
extension UIButton.Configuration {

    static func bottomSheetButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 18
        config.contentInsets = .init(top: 12, leading: 4, bottom: 12, trailing: 4)
        config.titleAlignment = .center
        config.titleLineBreakMode = .byTruncatingTail
        return config
    }
}
