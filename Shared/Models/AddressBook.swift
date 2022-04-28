//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation

class AddressBook {

    private(set) var me: Contact?
    private(set) var contacts: [Contact]
    static private (set) var instance: AddressBook = AddressBook()

    private init() {
        contacts = []
    }

    func findContact(userID: String) -> Contact? {
        contacts.first { $0.userID == userID }
    }

    func update(withUserIDs userIDs: [String], currentUser: String) {
        for userID in userIDs {
            let contact = ContactsGenerator.contact(userID)

            if userID == currentUser {
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
