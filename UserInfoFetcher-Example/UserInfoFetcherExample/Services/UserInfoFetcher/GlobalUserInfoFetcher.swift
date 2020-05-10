//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import Bandyer

class GlobalUserInfoFetcher: NSObject, BDKUserInfoFetcher {

    static var instance: GlobalUserInfoFetcher?

    var addressBook: AddressBook? {
        didSet {
            guard let book = addressBook else {
                return
            }

            aliasMap = ContactsMapGenerator(with: book).createAliasMap()
        }
    }

    private var aliasMap: [String: Contact]?

    override init() {
        super.init()

        GlobalUserInfoFetcher.instance = self
    }

    func fetchUsers(_ aliases: [String], completion: @escaping ([BDKUserInfoDisplayItem]?) -> Void) {
        let items = aliases.compactMap { (alias) -> BDKUserInfoDisplayItem? in
            guard let contact = aliasMap?[alias] else {
                return nil
            }

            //Suppose globally we want to have all the fields available.
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
        let fetcher = GlobalUserInfoFetcher()
        fetcher.addressBook = self.addressBook
        return fetcher
    }
}
