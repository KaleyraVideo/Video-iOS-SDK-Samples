//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import Foundation

struct AddressBook {

    private (set) var me: Contact?
    private (set) var contacts: [Contact]

    init(_ aliases: [String], currentUser: String) {

        contacts = []

        for alias in aliases {
            let contact = ContactsGenerator.contact(alias)

            if alias == currentUser {
                me = contact
            } else {
                contacts.append(contact)
            }
        }
    }
}
