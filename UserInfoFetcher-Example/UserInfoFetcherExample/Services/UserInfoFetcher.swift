//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import Bandyer

class UserInfoFetcher: NSObject, BDKUserInfoFetcher {

    private let addressBook: AddressBook

    private let aliasMap: [String: Contact]

    init(addressBook: AddressBook) {
        self.addressBook = addressBook
        self.aliasMap = ContactsMapGenerator(with: addressBook).createAliasMap()
    }

    func fetchUsers(_ aliases: [String], completion: @escaping ([BDKUserInfoDisplayItem]?) -> Void) {
        let items = aliases.compactMap { (alias) -> BDKUserInfoDisplayItem? in
            guard let contact = aliasMap[alias] else {
                return nil
            }

            //Suppose we want to have all the fields available.
            let item = BDKUserInfoDisplayItem(alias: alias)
            item.firstName = contact.firstName
            item.lastName = contact.lastName
            item.email = contact.email
            item.imageURL = contact.profileImageURL
            return item
        }

        completion(items)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let fetcher = UserInfoFetcher(addressBook: self.addressBook)
        return fetcher
    }
}
