// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension String {

    var trimmingWhitespacesAndNewLines: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
