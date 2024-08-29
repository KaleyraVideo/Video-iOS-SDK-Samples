//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import KaleyraVideoSDK

class CallOptionsItem: NSCopying {

    var type: CallOptions.CallType
    var recordingType: CallOptions.RecordingType?
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
