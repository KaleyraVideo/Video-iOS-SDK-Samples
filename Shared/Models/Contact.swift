//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation

enum Gender {
    case unknown
    case male
    case female
}

struct Contact: Hashable {

    var userID: String
    var firstName: String?
    var lastName: String?
    var fullName: String? {
        guard let first = firstName, let last = lastName else {
            return nil
        }

        return "\(first) \(last)"
    }

    var gender: Gender
    var email: String?
    var age: UInt?
    var profileImageURL: URL?

    init(_ userID: String) {
        self.userID = userID
        gender = .unknown
    }
}
