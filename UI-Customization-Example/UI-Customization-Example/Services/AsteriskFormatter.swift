//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Bandyer

//This formatter will print first name and last name separated by an asterisk
class AsteriskFormatter: Formatter {

    override func string(for obj: Any?) -> String? {
        guard let items = obj as? [BDKUserInfoDisplayItem], let item = items.first else {
            return nil
        }

        return (item.firstName ?? "") + " * " + (item.lastName ?? "")
    }
}
