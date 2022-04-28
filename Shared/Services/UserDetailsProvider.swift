//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Bandyer
import CallKit

class UserDetailsProvider: Bandyer.UserDetailsProvider {

    private let addressBook: AddressBook

    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
    }

    func provideDetails(_ userIds: [String], completion: @escaping ([UserDetails]) -> Void) {
        let items = userIds.map { userID -> UserDetails in
            let contact = addressBook.findContact(userID: userID)

            return UserDetails(userID: userID,
                               firstname: contact?.firstName,
                               lastname: contact?.lastName,
                               email: contact?.email,
                               imageURL: contact?.profileImageURL)
        }
        
        completion(items)
    }
    
    func provideHandle(_ userIds: [String], completion: @escaping (CXHandle) -> Void) {
        let names = userIds.map({ addressBook.findContact(userID: $0)?.fullName ?? $0 })
        let handle = CXHandle(type: .generic, value: names.joined(separator: ", "))
        completion(handle)
    }
}
