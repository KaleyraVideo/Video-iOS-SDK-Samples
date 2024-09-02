// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct Versions {

    let app: Version
    let sdk: Version

    init() {
        self.init(app: .app, sdk: .sdk)
    }

    init(app: Version, sdk: Version) {
        self.app = app
        self.sdk = sdk
    }
}
