//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import BandyerSDK

class CallUserInfoFetcher: NSObject, BDKUserInfoFetcher {
    
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
            
            //Suppose for a call we want to show only first name, last name and the user profile image
            let item = BDKUserInfoDisplayItem(alias: alias)
            item.firstName = contact.firstName
            item.lastName = contact.lastName
            item.imageURL = contact.profileImageURL
            return item
        }
        
        completion(items)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return CallUserInfoFetcher(addressBook: self.addressBook)
    }
}
