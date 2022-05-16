//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Bandyer

class CallOptionsItem: NSCopying {

    var type: CallType
    var recordingType: CallRecordingType
    var maximumDuration: UInt

    init() {
        type = .audioVideo
        recordingType = .none
        maximumDuration = 0
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CallOptionsItem()
        copy.type = type
        copy.recordingType = recordingType
        copy.maximumDuration = maximumDuration
        return copy
    }
}
