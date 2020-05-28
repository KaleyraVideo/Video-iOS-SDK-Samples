//
// Created by Marco Brescianini on 2019-02-25.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import Foundation

struct AddressBook {

    let me: Contact?
    let contacts: [Contact]

    init(_ aliases: [String], currentUser: String?) {
        
        self.contacts = aliases.compactMap { (alias) -> Contact? in
            guard alias != currentUser else {
                return nil
            }
            return ContactsGenerator.contact(alias)
        }
        
        if let meAlias = aliases.first(where: { $0 == currentUser }) {
            self.me = ContactsGenerator.contact(meAlias)
        } else {
            self.me = nil
        }
    }
}
