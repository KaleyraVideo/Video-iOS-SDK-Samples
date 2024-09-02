// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

struct Weak<Object: AnyObject> {
    private(set) weak var object: Object?

    init(object: Object) {
        self.object = object
    }
}
