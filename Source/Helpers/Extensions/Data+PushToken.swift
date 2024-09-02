// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension Data {

    var pushToken: String {
        map { String(format: "%02.2hhx", $0) }.joined()
    }
}
