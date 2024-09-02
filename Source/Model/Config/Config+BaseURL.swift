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
            case .europe:
                return "eu"
            case .india:
                return "in"
            case .us:
                return "us"
            case .middleEast:
                return "me"
        }
    }

    private var environmentDomain: String {
        switch environment {
            case .production:
                return ""
            case .sandbox:
                return ".sandbox"
            case .development:
                return ".development"
        }
    }

}
