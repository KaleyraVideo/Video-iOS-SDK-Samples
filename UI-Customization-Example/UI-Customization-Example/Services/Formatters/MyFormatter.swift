//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Bandyer

class MyFormatter: Formatter {

    func string(for items: [UserDetails], eachItemPrecededBy symbol: String) -> String {
        let values = items.map { item -> String in
            string(for: item, precededBy: symbol)
        }

        return values.joined(separator: " ")
    }

    func string(for item: UserDetails, precededBy symbol: String) -> String {
        let value: String
        if item.firstname == nil && item.lastname == nil {
            value = item.alias
        } else {
            value = (item.firstname ?? "") + " " + (item.lastname ?? "")
        }
        return symbol + " " + value
    }
}
