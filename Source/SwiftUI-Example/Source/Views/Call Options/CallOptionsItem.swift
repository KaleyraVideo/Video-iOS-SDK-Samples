//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import KaleyraVideoSDK

class CallOptionsItem: ObservableObject {

    @Published var type: CallType
    @Published var recordingType: CallRecordingType
    @Published var maximumDuration: UInt

    init() {
        type = .audioVideo
        recordingType = .none
        maximumDuration = 0
    }
}
