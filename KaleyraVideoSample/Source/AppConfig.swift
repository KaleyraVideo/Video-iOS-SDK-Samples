//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation
import CallKit
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

extension AppConfig {

    func makeSDKConfig(pushRegistryDelegate: PKPushRegistryDelegate?) -> Config {
        let config = createSDKConfig()
        setupCallKit(config, registryDelegate: pushRegistryDelegate)
        setupTools(config)
        return config
    }

    private func createSDKConfig() -> Config {
        let config = Config()

        // Here we are telling the SDK we want to work in a sandbox environment.
        // Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
        config.environment = environment
        return config
    }

    private func setupCallKit(_ config: Config, registryDelegate: PKPushRegistryDelegate?) {
        if isCallkitEnabled {
            enableCallKit(config, registryDelegate: registryDelegate)
        } else {
            disableCallKit(config)
        }
    }

    // If you don't want to support CallKit
    // you can set the isCallKitEnabled flag to false
    // Beware though, if CallKit is disabled the call will end if the user leaves the app while a call is in progress
    private func disableCallKit(_ config: Config) {
        // Here we are disabling CallKit support.
        // Make sure to disable CallKit, otherwise it will be enable by default
        config.isCallKitEnabled = false
    }

    // If you want to support CallKit, then:
    // CallKit framework must be linked to your app and it must linked as a required framework,
    // otherwise the app will have a weird behaviour when it is launched upon receiving a VoIP notification.
    // Please check the project "Build Settings" tab under the "Other Linker Flags" directive that the CallKit
    // framework is linked as required framework
    private func enableCallKit(_ config: Config, registryDelegate: PKPushRegistryDelegate?) {
        // On iOS 10 and above this statement is not needed, the default configuration object
        // enables CallKit by default, it is here for completeness sake
        config.isCallKitEnabled = true

        // The following statement is going to change the name of the app that is going to be shown by the system call UI.
        // If you don't set this value during the configuration, the SDK will look for to the value of the
        // CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App Info.plist

        config.nativeUILocalizedName = "My wonderful app"

        // The following statement is going to change the ringtone used by the system call UI when an incoming call
        // is received. You should provide the name of the sound resource in the app bundle that is going to be used as
        // ringtone. If you don't set this value, the SDK will use the default system ringtone.

        // config.nativeUIRingToneSound = "MyRingtoneSound"

        // The following statements are going to change the app icon shown in the system call UI. When the user answers
        // a call from the lock screen or when the app is not in foreground and a call is in progress, the system
        // presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
        // app. The following statements allows you to change that icon.
        // Beware, the configuration object property expects the image as an NSData object. You must provide a side
        // length 40 points square png image.
        // It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.

        let callKitIcon = UIImage(named: "callkit-icon")
        config.nativeUITemplateIconImageData = callKitIcon?.pngData()

        // The following statements will tell the BandyerSDK which type of handle the SDK should use with CallKit
        config.supportedHandleTypes = Set(arrayLiteral: NSNumber(integerLiteral: CXHandle.HandleType.generic.rawValue))

        if let registryDelegate = registryDelegate {
            // The following statement is going to tell the BandyerSDK which object it must forward device push tokens to when one is received.
            config.pushRegistryDelegate = registryDelegate
        }
    }

    private func setupTools(_ config: Config) {
        setupBroadcastScreensharing(config)
        setupInAppScreensharing(config)
        setupFileSharing(config)
        setupWhiteboard(config)
    }

    private func setupInAppScreensharing(_ config: Config) {
        if isInAppScreensharingEnabled {
            config.inAppScreensharingConfiguration = .enabled()
        } else {
            config.inAppScreensharingConfiguration = .disabled()
        }
    }

    // If you don't want to support the broadcast screen sharing feature
    // Comment the body of this method
    private func setupBroadcastScreensharing(_ config: Config) {
        if #available(iOS 12.0, *) {
            if isBroadcastScreensharingEnabled {
                // This configuration object enable the sdk to talk with the broadcast extension
                // You must provide the app group identifier used by your app and the upload extension bundle identifier

                config.broadcastScreensharingConfiguration = BroadcastScreensharingToolConfiguration.enabled(appGroupIdentifier: Constants.AppGroupIdentifier,
                                                                                                                broadcastExtensionBundleIdentifier: Constants.BroadcastExtensionBundleId)
            } else {
                config.broadcastScreensharingConfiguration = .disabled()
            }
        }
    }

    private func setupFileSharing(_ config: Config) {
        if isFilesharingEnabled {
            config.fileshareConfiguration = .enabled()
        } else {
            config.fileshareConfiguration = .disabled()
        }
    }

    private func setupWhiteboard(_ config: Config) {
        if isWhiteboardEnabled {
            config.whiteboardConfiguration = .enabled(withUploadEnabled: true)
        } else {
            config.whiteboardConfiguration = .disabled()
        }
    }
}
