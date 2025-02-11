// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension Config {

    var apiURL: URL {
        URL(string: "https://api" + environmentDomain + "." + regionDomain + ".bandyer.com")!
    }

    var baseURL: URL {
        URL(string: "https://cs" + environmentDomain + "." + regionDomain + ".bandyer.com")!
    }

    private var regionDomain: String {
        switch region {
            case .europe: "eu"
            case .india: "in"
            case .us: "us"
            case .middleEast: "me"
        }
    }

    private var environmentDomain: String {
        switch environment {
            case .production:  ""
            case .sandbox: ".sandbox"
            case .development: ".development"
        }
    }

}
