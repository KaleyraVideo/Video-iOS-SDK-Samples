// Copyright © 2020 Bandyer. All rights reserved.
// See LICENSE for licensing information

import Foundation
import CallKit
import Bandyer

class HandleProvider: NSObject, BCXHandleProvider {

    private let addressBook: AddressBook

    init(addressBook: AddressBook) {
        self.addressBook = addressBook
    }

    func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    func handle(forAliases aliases: [String]?, completion: @escaping (CXHandle) -> Void) {
        guard let aliases = aliases else {
            completion(CXHandle(type: .generic, value: "Unknown"))
            return
        }

        let value = aliases.compactMap { addressBook.findContact(alias: $0)?.fullName ?? "Unknown"}.joined(separator: ", ")
        completion(CXHandle(type: .generic, value: value))
    }
}
