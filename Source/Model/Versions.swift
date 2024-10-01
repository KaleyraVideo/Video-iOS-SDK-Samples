// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct Versions {

    let app: Version
    let sdk: Version?

    init() {
        if #available(iOS 15.0, *) {
            self.init(app: .app, sdk: .sdk)
        } else {
            self.init(app: .app, sdk: nil)
        }
    }

    init(app: Version, sdk: Version?) {
        self.app = app
        self.sdk = sdk
    }
}
