//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation
import CallKit
import KaleyraVideoSDK
import PushKit

struct AppConfig {

    var environment: Environment = .sandbox
    var region: Region = .europe

#if targetEnvironment(simulator)
    var isCallkitEnabled = false
#else
    var isCallkitEnabled = true
#endif

    var automaticallyHandleVoIPNotifications = true

    var isFilesharingEnabled = true
    var isInAppScreensharingEnabled = true
    var isWhiteboardEnabled = true
    var isBroadcastScreensharingEnabled = true
    var isChatEnabled = true

    static let `default` = AppConfig()
}

extension AppConfig {

    func makeSDKConfig() throws -> Config {
        var config = Config(appID: Constants.AppId, region: region, environment: environment)
        config.callKit = isCallkitEnabled ? .enabled(.init(icon: UIImage(named: "callkit-icon"))) : .disabled
        config.voip = automaticallyHandleVoIPNotifications ? .automatic(listenForNotificationsInForeground: false) : .manual
        config.tools.chat = isChatEnabled ? .enabled : .disabled
        config.tools.whiteboard = isWhiteboardEnabled ? .enabled(isUploadEnabled: true) : .disabled
        config.tools.fileshare = isFilesharingEnabled ? .enabled : .disabled
        config.tools.inAppScreenSharing = isInAppScreensharingEnabled ? .enabled : .disabled
        config.tools.broadcastScreenSharing = isBroadcastScreensharingEnabled ? .enabled(appGroupIdentifier: try .init(Constants.AppGroupIdentifier), extensionBundleIdentifier: Constants.BroadcastExtensionBundleId) : .disabled
        return config
    }
}
