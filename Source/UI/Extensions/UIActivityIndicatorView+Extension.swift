// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIActivityIndicatorView {

    convenience init(style: UIActivityIndicatorView.Style, running: Bool) {
        self.init(style: style)
        guard running else { return }
        startAnimating()
    }
}
