//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation
import Bandyer
import CallKit

class UserDetailsProvider: Bandyer.UserDetailsProvider {

    private let addressBook: AddressBook
    private let aliasMap: [String: Contact]

    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
        var aliasMap: [String: Contact] = [:]

        for contact in addressBook.contacts {
            aliasMap.updateValue(contact, forKey: contact.alias)
        }
        
        if let me = addressBook.me {
            aliasMap.updateValue(me, forKey: me.alias)
        }

        self.aliasMap = aliasMap
    }

    func provideDetails(_ aliases: [String], completion: @escaping ([UserDetails]) -> Void) {
        let items = aliases.map { alias -> UserDetails in
            let contact = aliasMap[alias]

            let item = UserDetails(alias: alias,
                                   firstname: contact?.firstName,
                                   lastname: contact?.lastName,
                                   email: contact?.email,
                                   imageURL: contact?.profileImageURL)
            
            return item
        }
        
        completion(items)
    }
    
    func provideHandle(_ aliases: [String], completion: @escaping (CXHandle) -> Void) {
        let names = aliasMap.filter({ aliases.contains($0.key) }).map({ $0.value.fullName ?? $0.key })
        let handle = CXHandle(type: .generic, value: names.joined(separator: ", "))
        completion(handle)
    }
}
