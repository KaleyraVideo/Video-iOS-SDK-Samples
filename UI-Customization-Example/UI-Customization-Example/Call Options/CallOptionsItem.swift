//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import Bandyer

class CallOptionsItem: NSCopying {

    var type: BDKCallType
    var record: Bool
    var maximumDuration: UInt

    init() {
        type = .audioVideo
        record = false
        maximumDuration = 0
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CallOptionsItem()
        copy.type = type
        copy.record = record
        copy.maximumDuration = maximumDuration

        return copy
    }
}
