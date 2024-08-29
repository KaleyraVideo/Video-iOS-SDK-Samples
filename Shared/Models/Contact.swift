//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation
import CallKit
import KaleyraVideoSDK

struct Contact: Hashable {

    enum Gender {
        case male
        case female
    }

    var userID: String
    var firstName: String?
    var lastName: String?
    var fullName: String? {
        guard let first = firstName, let last = lastName else {
            return nil
        }

        return "\(first) \(last)"
    }

    var gender: Gender?
    var email: String?
    var age: UInt?
    var profileImageURL: URL?

    var handle: CXHandle? {
        guard let fullName else { return nil }
        return .init(type: .generic, value: fullName)
    }

    var userDetails: UserDetails {
        .init(userID: userID, displayName: fullName, imageURL: profileImageURL, handle: handle)
    }

    init(_ userID: String) {
        self.userID = userID
    }
}
