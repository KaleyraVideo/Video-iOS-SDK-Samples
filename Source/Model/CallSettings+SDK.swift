// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension CallSettings.Tools {

    var asSDKSettings: KaleyraVideoSDK.ConferenceSettings.Tools {
        var config = KaleyraVideoSDK.ConferenceSettings.Tools.default
        config.chat = isChatEnabled ? .enabled : .disabled
        config.broadcastScreenSharing = isBroadcastEnabled ? .enabled(appGroupIdentifier: .kaleyra,
                                                                      extensionBundleIdentifier: .extensionIdentifier) : .disabled
        config.fileshare = isFileshareEnabled ? .enabled : .disabled
        config.inAppScreenSharing = isScreenshareEnabled ? .enabled : .disabled
        config.whiteboard = isWhiteboardEnabled ? .enabled : .disabled
        return config
    }
}

private extension AppGroupIdentifier {

    static var kaleyra: AppGroupIdentifier { try! .init("group.com.bandyer.BandyerSDKSample") }
}

private extension String {

    static var extensionIdentifier: String { "com.bandyer.BandyerSDKSample.BroadcastExtension" }
}
