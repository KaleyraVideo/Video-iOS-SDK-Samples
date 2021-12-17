//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

import Bandyer
import CallKit

class UserDetailsProvider: Bandyer.UserDetailsProvider {

    private let addressBook: AddressBook

    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
    }

    func provideDetails(_ aliases: [String], completion: @escaping ([UserDetails]) -> Void) {
        let items = aliases.map { alias -> UserDetails in
            let contact = addressBook.findContact(alias: alias)

            return UserDetails(alias: alias,
                               firstname: contact?.firstName,
                               lastname: contact?.lastName,
                               email: contact?.email,
                               imageURL: contact?.profileImageURL)
        }
        
        completion(items)
    }
    
    func provideHandle(_ aliases: [String], completion: @escaping (CXHandle) -> Void) {
        let names = aliases.map({ addressBook.findContact(alias: $0)?.fullName ?? $0 })
        let handle = CXHandle(type: .generic, value: names.joined(separator: ", "))
        completion(handle)
    }
}
