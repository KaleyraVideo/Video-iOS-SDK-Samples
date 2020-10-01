//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Foundation

class UserSession {

    class var currentUser: String? {
        get {
            UserDefaults.standard.object(forKey: "com.acme.logged_user_id") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "com.acme.logged_user_id")
            UserDefaults.standard.synchronize()
        }
    }
}
