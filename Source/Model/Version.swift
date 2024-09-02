// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct Version {

    let marketing: String
    let build: String?

    init(marketing: String, build: String? = nil) {
        self.marketing = marketing
        self.build = build
    }
}

extension Version {

    init(bundle: Bundle) {
        self.marketing = bundle.version!
        self.build = bundle.build
    }

    static let app: Version = .init(bundle: .main)
    static let sdk: Version = .init(bundle: .sdk)
}
