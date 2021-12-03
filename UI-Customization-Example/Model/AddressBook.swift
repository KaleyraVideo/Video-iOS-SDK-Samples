//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Foundation

class AddressBook {

    private (set) var me: Contact?
    private (set) var contacts: [Contact] = []
    static private (set) var instance: AddressBook = AddressBook()

    private init() {}

    func findContact(alias: String) -> Contact? {
        contacts.first { $0.alias == alias }
    }

    func update(withAliases aliases: [String], currentUser: String) {
        for alias in aliases {
            let contact = ContactsGenerator.contact(alias)

            if alias == currentUser {
                me = contact
            } else {
                contacts.append(contact)
            }
        }
    }

    func cleanUp() {
        me = nil
        contacts.removeAll()
    }
}
