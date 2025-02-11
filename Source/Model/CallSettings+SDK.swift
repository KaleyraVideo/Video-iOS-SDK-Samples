// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension CallSettings.Tools {

    var asSDKSettings: KaleyraVideoSDK.ConferenceSettings.Tools {
        var config = KaleyraVideoSDK.ConferenceSettings.Tools.default
        config.chat = isChatEnabled ? .enabled : .disabled
#if DEMO_PRIVATE
        config.broadcastScreenSharing = isBroadcastEnabled ? .enabled(appGroupIdentifier: .kaleyra,
                                                                      extensionBundleIdentifier: .appExtensionIdentifier) : .disabled
#endif
        config.fileshare = isFileshareEnabled ? .enabled : .disabled
        config.inAppScreenSharing = isScreenshareEnabled ? .enabled : .disabled
        config.whiteboard = isWhiteboardEnabled ? .enabled : .disabled
        return config
    }
}
