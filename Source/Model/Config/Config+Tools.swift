// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension Config {

    struct Tools: Codable, Equatable {

        var isChatEnabled = true
        var isWhiteboardEnabled = true
        var isFileshareEnabled = true
        var isScreenshareEnabled = true
        var isBroadcastEnabled = true

        static let `default`: Tools = .init()
    }
}
