//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation
import CallKit
import Bandyer
import PushKit

struct AppConfig {

    var environment: Environment = .sandbox
    var region: Region = .europe

    var isCallkitEnabled = true

    var automaticallyHandleVoIPNotifications = true

    var isFilesharingEnabled = true
    var isInAppScreensharingEnabled = true
    var isWhiteboardEnabled = true
    var isBroadcastScreensharingEnabled = true
    var isChatEnabled = true

    static let `default` = AppConfig()
}

extension AppConfig {

    func makeSDKConfig(pushRegistryDelegate: PKPushRegistryDelegate?) -> Config {
        let builder = createSDKConfig()
        setupVoIPNotifications(builder, registryDelegate: pushRegistryDelegate)
        setupCallKit(builder)
        setupTools(builder)
        return try! builder.build()
    }

    private func createSDKConfig() -> ConfigBuilder {

        // Here we are telling the SDK the app id token identifying your app in Bandyer platform, the region and the environment to connect to.
        // We strongly recommend to test your app in a sandbox environment before deploying it to production.
        let builder = ConfigBuilder(appID: Constants.AppId, environment: environment, region: region)

        return builder
    }

    private func setupVoIPNotifications(_ builder: ConfigBuilder, registryDelegate: PKPushRegistryDelegate?) {
        _ = builder.voip { voipBuilder in
            if let registryDelegate = registryDelegate, automaticallyHandleVoIPNotifications {
                //This is how you enable automatic VoIP notification handling.
                voipBuilder.automatic(pushRegistryDelegate: registryDelegate)
            } else if !automaticallyHandleVoIPNotifications {
                //This is how you enable manual VoIP notification handling.
                voipBuilder.manual()
            }
        }
    }

    private func setupCallKit(_ builder: ConfigBuilder) {
        _ = builder.callKit({ callKitBuilder in
            if isCallkitEnabled {
                enableCallKit(callKitBuilder)
            } else {
                disableCallKit(callKitBuilder)
            }
        })
    }

    // If you don't want to support CallKit
    // you can set the isCallKitEnabled flag to false
    // Beware though, if CallKit is disabled the call will end if the user leaves the app while a call is in progress
    private func disableCallKit(_ builder: CallKitConfigurationBuilder) {
        // Here we are disabling CallKit support.
        // Make sure to disable CallKit, otherwise it will be enable by default
        builder.disabled()
    }

    // If you want to support CallKit, then:
    // CallKit framework must be linked to your app and it must linked as a required framework,
    // otherwise the app will have a weird behavior when it is launched upon receiving a VoIP notification.
    // Please check the project "Build Settings" tab under the "Other Linker Flags" directive that the CallKit
    // framework is linked as required framework
    private func enableCallKit(_ builder: CallKitConfigurationBuilder) {
        
        builder.enabled { callKitProviderConfBuilder in

            callKitProviderConfBuilder
            // The following statement is going to change the ringtone used by the system call UI when an incoming call
            // is received. You should provide the name of the sound resource in the app bundle that is going to be used as
            // ringtone. If you don't set this value, the SDK will use the default system ringtone.
                .ringtoneSound("MyRingtoneSound")
            // The following statements will tell the BandyerSDK which type of handle the SDK should use with CallKit
                .supportedHandles([.generic])

            if let callKitIcon = UIImage(named: "callkit-icon") {
                // The following statements are going to change the app icon shown in the system call UI. When the user answers
                // a call from the lock screen or when the app is not in foreground and a call is in progress, the system
                // presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
                // app. The following statements allows you to change that icon.
                // You must provide a side length 40 points square png image.
                // It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.
                callKitProviderConfBuilder.icon(callKitIcon)
            }
        }
    }

    private func setupTools(_ builder: ConfigBuilder) {
        _ = builder.tools { toolsBuilder in
            setupBroadcastScreensharing(toolsBuilder)
            setupInAppScreensharing(toolsBuilder)
            setupFileSharing(toolsBuilder)
            setupWhiteboard(toolsBuilder)
            setupChat(toolsBuilder)
        }
    }

    private func setupInAppScreensharing(_ builder: ToolsConfigurationBuilder) {
        if isInAppScreensharingEnabled {
            // This is how you enable in-app screen sharing tool. By default this tool is disabled.
            builder.inAppScreenSharing()
        }
    }

    // If you don't want to support the broadcast screen sharing feature
    // Comment the body of this method
    private func setupBroadcastScreensharing(_ builder: ToolsConfigurationBuilder) {

        if isBroadcastScreensharingEnabled {
            // This configuration object enable the sdk to talk with the broadcast extension
            // You must provide the app group identifier used by your app and the upload extension bundle identifier
            // By default this tool is disabled.
            builder.broadcastScreenSharing(appGroupIdentifier: Constants.AppGroupIdentifier, broadcastExtensionBundleIdentifier: Constants.BroadcastExtensionBundleId)
        }
    }

    private func setupFileSharing(_ builder: ToolsConfigurationBuilder) {
        if isFilesharingEnabled {
            // This is how you enable fileshare tool. By default this tool is disabled.
            builder.fileshare()
        }
    }

    private func setupWhiteboard(_ builder: ToolsConfigurationBuilder) {
        if isWhiteboardEnabled {
            // This is how you enable whiteboard tool. By default this tool is disabled.
            builder.whiteboard(uploadEnabled: true)
        }
    }

    private func setupChat(_ builder: ToolsConfigurationBuilder) {
        if isChatEnabled {
            // This is how you enable chat tool. By default this tool is disabled.
            builder.chat()
        }
    }
}
