//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

import Bandyer

//This formatter will print first name and last name separated by an asterisk
class AsteriskFormatter: Formatter {

    override func string(for obj: Any?) -> String? {
        guard let items = obj as? [UserDetails], let item = items.first else {
            return nil
        }

        return (item.firstname ?? "") + " * " + (item.lastname ?? "")
    }
}
