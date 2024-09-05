// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIBarButtonItem {

    func simulateTapped() {
        _ = target?.perform(action, with: self)
    }
}
