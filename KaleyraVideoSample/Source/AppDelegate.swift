//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit
import PushKit
import Intents
import CallKit
import Bandyer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Before we can get started, if you want to enable CallKit and VoIP notifications you
    // must review your project configuration, and enable the required app capabilities .
    // Namely, you must enable "Background modes" capability
    // checking "Audio, AirPlay and Picture in Picture" and "Voice over IP" checkboxes on.
    // You must also enable "Push notifications" capability even if you use VoIP notifications only.
    //
    // Privacy usage descriptions:
    // You must add NSCameraUsageDescription and NSMicrophoneUsageDescription to your app Info.plist file.
    // Those values are required to access microphone and camera. In this sample app, those values have been already added for you.
    // Consider also to add NSPhotoLibraryUsageDescription key into app Info.plist in case you want your users to upload photos on our services.
    //
    // If your build target supports systems earlier than iOS 11, please add iCloud entitlement with at least Key-value storage checked,
    // otherwise your app is going to crash anytime the user try to upload a document from iCloud.
    // In this sample app, this is already done for you inside 'Signing & Capabilities' tab of project settings.
    // To enable build on physical devices, you should disable bitcode on build settings tab of your target settings. In this sample app, this flag is already set for you.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Here we are going to initialize the Bandyer SDK
        // The sdk needs a configuration object where it is specified which environment the sdk should work in.
        let config = createSDKConfig()

        //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
        BandyerSDK.instance().initialize(withApplicationId: Constants.AppId,
                                         config: config)

        return true
    }

    private func createSDKConfig() -> Config {
        let sdkConfig = createSDKConfigFor(appConfig: .default)
        setupTools(appConfig: .default, sdkConfig: sdkConfig)
        return sdkConfig
    }

    private func createSDKConfigFor(appConfig: AppConfig) -> Config {
        if appConfig.isCallkitEnabled {
            return createConfigWithCallKitSupport(appConfig)
        } else {
            return createConfigWithoutCallKitSupport(appConfig)
        }
    }

    // If you don't want to support CallKit
    // you can set the isCallKitEnabled flag to false
    // Beware though, if CallKit is disabled the call will end if the user leaves the app while a call is in progress
    private func createConfigWithoutCallKitSupport(_ appConfig: AppConfig) -> Config {
        let config = Config()
        config.environment = appConfig.environment

        // Here we are disabling CallKit support.
        // Make sure to disable CallKit, otherwise it will be enable by default
        config.isCallKitEnabled = false
        return config
    }

    // If you want to support CallKit, then:
    // CallKit framework must be linked to your app and it must linked as a required framework,
    // otherwise the app will have a weird behaviour when it is launched upon receiving a VoIP notification.
    // Please check the project "Build Settings" tab under the "Other Linker Flags" directive that the CallKit
    // framework is linked as required framework
    private func createConfigWithCallKitSupport(_ appConfig: AppConfig) -> Config {
        let config = Config()

        //Here we are telling the SDK we want to work in a sandbox environment.
        //Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
        config.environment = appConfig.environment

        //On iOS 10 and above this statement is not needed, the default configuration object
        //enables CallKit by default, it is here for completeness sake
        config.isCallKitEnabled = true

        //The following statement is going to change the name of the app that is going to be shown by the system call UI.
        //If you don't set this value during the configuration, the SDK will look for to the value of the
        //CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App Info.plist

        config.nativeUILocalizedName = "My wonderful app"

        //The following statement is going to change the ringtone used by the system call UI when an incoming call
        //is received. You should provide the name of the sound resource in the app bundle that is going to be used as
        //ringtone. If you don't set this value, the SDK will use the default system ringtone.

        //config.nativeUIRingToneSound = "MyRingtoneSound"

        //The following statements are going to change the app icon shown in the system call UI. When the user answers
        //a call from the lock screen or when the app is not in foreground and a call is in progress, the system
        //presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
        //app. The following statements allows you to change that icon.
        //Beware, the configuration object property expects the image as an NSData object. You must provide a side
        //length 40 points square png image.
        //It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.

        let callKitIcon = UIImage(named: "callkit-icon")
        config.nativeUITemplateIconImageData = callKitIcon?.pngData()

        //The following statements will tell the BandyerSDK which type of handle the SDK should use with CallKit
        config.supportedHandleTypes = Set(arrayLiteral: NSNumber(integerLiteral: CXHandle.HandleType.generic.rawValue))
        //The following statement is going to tell the BandyerSDK which object it must forward device push tokens to when one is received.
        config.pushRegistryDelegate = self

        return config
    }

    private func setupTools(appConfig: AppConfig, sdkConfig: Config) {
        setupBroadcastScreensharing(appConfig: appConfig, sdkConfig: sdkConfig)
        setupInAppScreensharing(appConfig: appConfig, sdkConfig: sdkConfig)
    }

    private func setupInAppScreensharing(appConfig: AppConfig, sdkConfig: Config) {
        if appConfig.isInAppScreensharingEnabled {
            sdkConfig.inAppScreensharingConfiguration = .enabled()
        } else {
            sdkConfig.inAppScreensharingConfiguration = .disabled()
        }
    }

    // If you don't want to support the broadcast screen sharing feature
    // Comment the body of this method
    private func setupBroadcastScreensharing(appConfig: AppConfig, sdkConfig: Config) {
        if #available(iOS 12.0, *) {
            if appConfig.isBroadcastScreensharingEnabled {
                // This configuration object enable the sdk to talk with the broadcast extension
                // You must provide the app group identifier used by your app and the upload extension bundle identifier

                sdkConfig.broadcastScreensharingConfiguration = BroadcastScreensharingToolConfiguration.enabled(appGroupIdentifier: Constants.AppGroupIdentifier,
                                                                                                             broadcastExtensionBundleIdentifier: Constants.BroadcastExtensionBundleId)
            } else {
                sdkConfig.broadcastScreensharingConfiguration = .disabled()
            }
        }
    }
}

extension AppDelegate: PKPushRegistryDelegate {

    // When the system notifies the SDK of the new VoIP push token
    // The SDK will call this method (if set this instance as pushRegistryDelegate in the config object)
    // Providing you the push token. You should send the token received to your back-end system
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let token = pushCredentials.tokenAsString else { return }
        
        debugPrint("Push credentials updated \(token), you should send them to your backend system")
    }
}

extension AppDelegate {

    // When System call ui is shown to the user, it will show a "video" button if the call supports it.
    // The code below will handle the siri intent received from the system and it will hand it to the call view controller
    // if the controller is presented
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let siriIntent = userActivity.interaction?.intent else {
            return false
        }

        guard let window = CallWindow.instance else {
            return false
        }

        if #available(iOS 13.0, *) {
            if let startCallIntent = siriIntent as? INStartCallIntent {
                window.handle(startCallIntent: startCallIntent)
                return true
            }
        }

        if let videoCallIntent = siriIntent as? INStartVideoCallIntent {
            window.handle(startVideoCallIntent: videoCallIntent)
            return true
        }

        return false
    }
}

extension AppDelegate {

    func applyTheme() {
        let accentColor = UIColor.accentColor

        if #available(iOS 14.0, *) {
        } else {
            window?.tintColor = accentColor
        }

        //This is the core of your customisation possibility using Bandyer SDK theme.
        //Let's suppose that your app is highly customised. Setting the following properties will let you to apply your colors, bar properties and fonts to all Bandyer's view controllers.

        //Colors
        Theme.default().accentColor = accentColor
        Theme.default().primaryBackgroundColor = UIColor.customBackground
        Theme.default().secondaryBackgroundColor = UIColor.customSecondary
        Theme.default().tertiaryBackgroundColor = UIColor.customTertiary

        //Bars
        Theme.default().barTranslucent = false
        Theme.default().barStyle = .black
        Theme.default().keyboardAppearance = .dark
        Theme.default().barTintColor = UIColor.customBarTintColor

        //Fonts
        Theme.default().navBarTitleFont = UIFont.robotoMedium
        Theme.default().secondaryFont = UIFont.robotoLight
        Theme.default().bodyFont = UIFont.robotoThin
        Theme.default().font = UIFont.robotoRegular
        Theme.default().emphasisFont = UIFont.robotoBold
        Theme.default().mediumFontPointSize = 15
    }

    func customizeInAppNotification() {
        //Only after the SDK is initialized, you can change the In-app notification theme and set a custom formatter.
        //If you try to set the theme or the formatter before SDK initialization, the notificationsCoordinator will be nil and sets will not be applied.
        //The formatter will be used to display the user information on the In-app notification heading.

        let theme = Theme()
        theme.secondaryFont = UIFont.robotoRegular.withSize(5)

        BandyerSDK.instance().notificationsCoordinator?.theme = theme
        BandyerSDK.instance().notificationsCoordinator?.formatter = HashtagFormatter()
    }
}
