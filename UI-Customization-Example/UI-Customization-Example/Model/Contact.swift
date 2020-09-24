//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Foundation

enum Gender{
    case unknown
    case male
    case female
}

struct Contact{

    var alias : String
    var firstName : String?
    var lastName : String?
    var fullName : String?{
        guard let first = firstName, let last = lastName else {
            return nil
        }

        return "\(first) \(last)"
    }

    var gender : Gender
    var email : String?
    var age : UInt?
    var profileImageURL :URL?

    init (_ alias:String){
        self.alias = alias
        gender = .unknown
    }
}
