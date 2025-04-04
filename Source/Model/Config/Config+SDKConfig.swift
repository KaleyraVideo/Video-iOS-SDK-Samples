// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Config {

    var sdk: KaleyraVideoSDK.Config {
        var config = KaleyraVideoSDK.Config(appID: keys.appId.description,
                                            region: region.sdkRegion,
                                            environment: environment.sdkEnvironment)
#if targetEnvironment(simulator)
        config.callKit = .disabled
#else
        config.callKit = .enabled(.init(icon: Icons.callkit))
#endif
        config.voip = voip.sdk
        config.shouldListenForDirectIncomingCalls = !disableDirectIncomingCalls
#if DEMO_PRIVATE
        config.broadcast = .init(appGroupIdentifier: .kaleyra, extensionBundleIdentifier: .appExtensionIdentifier)
#endif

        return config
    }
}

extension Config.VoIP {

    var sdk: KaleyraVideoSDK.Config.VoIP {
        switch self {
            case .disabled: .disabled
            case .manual: .manual
            case .automatic(strategy: let strategy): .automatic(listenForNotificationsInForeground: strategy == .always)
        }
    }
}
