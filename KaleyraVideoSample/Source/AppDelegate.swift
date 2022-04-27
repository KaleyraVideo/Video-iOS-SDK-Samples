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
        let config = AppConfig.default.makeSDKConfig(pushRegistryDelegate: self)
        
        //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
        BandyerSDK.instance().initialize(withApplicationId: Constants.AppId,
                                         config: config)

        return true
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
