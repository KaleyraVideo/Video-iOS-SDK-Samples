//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Bandyer

class MyFormatter: Formatter {

    func string(for items: [BDKUserInfoDisplayItem], eachItemPrecededBy symbol: String) -> String {
        let values = items.map { item -> String in
            string(for: item, precededBy: symbol)
        }

        return values.joined(separator: " ")
    }

    func string(for item: BDKUserInfoDisplayItem, precededBy symbol: String) -> String {
        let value: String
        if item.firstName == nil && item.lastName == nil {
            value = item.alias
        } else {
            value = (item.firstName ?? "") + " " + (item.lastName ?? "")
        }
        return symbol + " " + value
    }
}
