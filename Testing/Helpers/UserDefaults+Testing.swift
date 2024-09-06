// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension UserDefaults {

    static var testSuite: UserDefaults {
        .init(suiteName: .testSuite)!
    }
}

extension String {

    static let testSuite = "com.kaleyra_video.testing"
}
