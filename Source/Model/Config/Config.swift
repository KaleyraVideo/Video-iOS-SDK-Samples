// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

struct Config {

    static var logLevel: LogLevel = .all

    var keys: Config.Keys
    var environment: Config.Environment
    var region: Config.Region
    var showUserInfo: Bool
    var disableDirectIncomingCalls: Bool
    var voip: Config.VoIP

    init(keys: Config.Keys,
         showUserInfo: Bool = true,
         environment: Config.Environment = .sandbox,
         region: Config.Region = .europe,
         disableDirectIncomingCalls: Bool = false,
         voip: Config.VoIP = .default) {
        self.keys = keys
        self.environment = environment
        self.region = region
        self.showUserInfo = showUserInfo
        self.disableDirectIncomingCalls = disableDirectIncomingCalls
        self.voip = voip
    }
}
