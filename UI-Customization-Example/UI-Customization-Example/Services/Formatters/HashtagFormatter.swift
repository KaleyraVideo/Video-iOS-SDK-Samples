//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Bandyer

//This formatter will print first name and last name preceded by an hashtag.
class HashtagFormatter: MyFormatter {

    override func string(for obj: Any?) -> String? {
        let symbol = "#"
        if let items = obj as? [UserDetails] {
            return string(for: items, eachItemPrecededBy: symbol)
        }
        if let item = obj as? UserDetails {
            return string(for: item, precededBy: symbol)
        }

        return nil
    }
}
