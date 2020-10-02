//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Bandyer

//This formatter will print first name and last name preceded by a percentage.
class PercentageFormatter: MyFormatter {

    override func string(for obj: Any?) -> String? {
        let symbol = "%"
        if let items = obj as? [BDKUserInfoDisplayItem] {
            return string(for: items, eachItemPrecededBy: symbol)
        }
        if let item = obj as? BDKUserInfoDisplayItem {
            return string(for: item, precededBy: symbol)
        }

        return nil
    }
}
