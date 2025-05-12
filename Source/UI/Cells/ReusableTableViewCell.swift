// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit
import Foundation

class ReusableTableViewCell: UITableViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()

        accessoryType = .none
        textLabel?.text = nil
    }
}
