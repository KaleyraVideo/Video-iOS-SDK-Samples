//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import Foundation
import Bandyer

class CallOptionsItem : NSCopying{
    
    var type: BDKCallType
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
