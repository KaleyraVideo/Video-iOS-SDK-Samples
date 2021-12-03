//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import Foundation
import Bandyer

struct AppConfig {

    var environment: Environment = .sandbox

    var isCallkitEnabled = true

    var isFilesharingEnabled = true
    var isInAppScreensharingEnabled = true
    var isWhiteboardEnabled = true
    var isBroadcastScreensharingEnabled = true

    static let `default` = AppConfig()
}
