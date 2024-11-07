// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import CallKit
import KaleyraVideoSDK

struct ContactsUserDetailsProvider: UserDetailsProvider {

    let book: AddressBook

    func provideDetails(_ aliases: [String], completion: @escaping (Result<[KaleyraVideoSDK.UserDetails], Error>) -> Void) {
        completion(.success(aliases.compactMap({ book.contacts.first(identifiedBy: $0)?.userDetails })))
    }
}

private extension Collection where Element == Contact {

    func first(identifiedBy id: String) -> Element? {
        first(where: { $0.alias == id })
    }
}

extension Contact {

    var userDetails: KaleyraVideoSDK.UserDetails {
        .init(userId: alias, name: fullName, image: imageURL, handle: fullName.map({ .init(type: .generic, value: $0) }))
    }
}
