//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

import Bandyer

class CallOptionsItem: NSCopying {
    
    var type: CallType
    var record: Bool
    var maximumDuration:UInt
    
    init(){
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
