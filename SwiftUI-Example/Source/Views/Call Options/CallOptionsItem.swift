//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer

class CallOptionsItem: ObservableObject {

    @Published var type: CallType
    @Published var record: Bool
    @Published var maximumDuration: UInt

    init() {
        type = .audioVideo
        record = false
        maximumDuration = 0
    }
}
