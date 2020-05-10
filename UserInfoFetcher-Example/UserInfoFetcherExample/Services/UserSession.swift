//
// Created by Marco Brescianini on 2019-02-25.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import Foundation

class UserSession {

    class var currentUser: String? {
        get {
            UserDefaults.standard.object(forKey: "com.acme.logged_user_id") as! String?
        }
        set {
            UserDefaults.standard.set(newValue as String?, forKey: "com.acme.logged_user_id")
            UserDefaults.standard.synchronize()
        }
    }
}
