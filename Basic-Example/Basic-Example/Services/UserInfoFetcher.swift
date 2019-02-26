//
// Created by Marco Brescianini on 2019-02-26.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import Foundation
import BandyerSDK

class UserInfoFetcher: NSObject, BDKUserInfoFetcher {
    private let addressBook: AddressBook
    private let aliasMap: [String: Contact]

    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
        var aliasMap:[String: Contact] = [:]
        
        for contact in addressBook.contacts {
            aliasMap.updateValue(contact, forKey: contact.alias)
        }

        aliasMap.updateValue(addressBook.me!, forKey: addressBook.me!.alias)
        
        self.aliasMap = aliasMap
    }

    func fetchUsers(_ aliases: [String], completion: @escaping ([BDKUserInfoDisplayItem]?) -> Void) {

        var items:[BDKUserInfoDisplayItem] = []

        for alias in aliases {
            let contact = aliasMap[alias]
            let item = BDKUserInfoDisplayItem(alias: alias)
            item.firstName = contact?.firstName
            item.lastName = contact?.lastName
            item.email = contact?.email
            item.imageURL = contact?.profileImageURL

            items.append(item)
        }

        completion(items)
    }

    func copy(with zone: NSZone?) -> Any {
        return UserInfoFetcher(addressBook)
    }
}
