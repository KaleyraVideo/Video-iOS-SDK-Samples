//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import KaleyraVideoSDK
import CallKit

class UserDetailsProvider: KaleyraVideoSDK.UserDetailsProvider {
    private let addressBook: AddressBook

    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
    }

    func provideDetails(_ userIds: [String], completion: @escaping (Result<[KaleyraVideoSDK.UserDetails], any Error>) -> Void) {
        completion(.success(userIds.compactMap({ addressBook.findContact(userID: $0)?.userDetails })))
    }
}
