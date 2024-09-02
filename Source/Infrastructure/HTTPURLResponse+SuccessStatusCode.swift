// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension HTTPURLResponse {

    var hasSuccessfulStatusCode: Bool {
        (200..<300).contains(statusCode)
    }
}
