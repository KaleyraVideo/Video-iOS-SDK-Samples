// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Config {

    var sdk: KaleyraVideoSDK.Config {
        var config = KaleyraVideoSDK.Config(appID: keys.appId.description,
                                            region: region.sdkRegion,
                                            environment: environment.sdkEnvironment)
        config.tools.chat = tools.isChatEnabled ? .enabled : .disabled
        config.tools.broadcastScreenSharing = tools.isBroadcastEnabled ? .enabled(appGroupIdentifier: try! .init("group.com.bandyer.BandyerSDKSample"),
                                                                                  extensionBundleIdentifier: "com.bandyer.BandyerSDKSample.BroadcastExtension") : .disabled
        config.tools.fileshare = tools.isFileshareEnabled ? .enabled : .disabled
        config.tools.inAppScreenSharing = tools.isScreenshareEnabled ? .enabled : .disabled
        config.tools.whiteboard = tools.isWhiteboardEnabled ? .enabled(isUploadEnabled: true) : .disabled
#if targetEnvironment(simulator)
        config.callKit = .disabled
#else
        config.callKit = .enabled(.init(icon: Icons.callkit))
#endif
        config.voip = voip.sdk
        config.shouldListenForDirectIncomingCalls = !disableDirectIncomingCalls

        return config
    }
}

extension Config.VoIP {

    var sdk: KaleyraVideoSDK.Config.VoIP {
        switch self {
            case .disabled:
                .disabled
            case .manual:
                .manual
            case .automatic(strategy: let strategy):
                .automatic(listenForNotificationsInForeground: strategy == .always)
        }
    }
}
