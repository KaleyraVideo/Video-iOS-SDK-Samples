//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import UIKit
import Bandyer
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //Before we dive into the details of how the SDK must be configured and initialized
        //you should add NSCameraUsageDescription and NSMicrophoneUsageDescription keys into app Info.plist
        //if you haven't done so already, otherwise your app is going to crash anytime it tries to access camera
        //or microphone devices. In this sample app, those values have been already added for you.

        //Consider also to add NSPhotoLibraryUsageDescription key into app Info.plist in case you want your users to upload photos on our services.

        //If your build target is less than iOS 11, please add iCloud entitlement with at least Key-value storage checked,
        //otherwise your app is going to crash anytime the user try to upload a document from iCloud.
        //In this sample app, this is already done for you inside 'Signing & Capabilities' tab of project settings.

        //To enable build on physical devices, you should disable bitcode on build settings tab of your target settings. In this sample app, this flag is already set for you.

        //Here we are going to initialize the Bandyer SDK.
        //The sdk needs a configuration object where it is specified which environment the sdk should work in.
        let config = BDKConfig()

        //Here we are telling the SDK we want to work in a sandbox environment.
        //Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
        config.environment = .sandbox

        //On iOS 10 and above this statement is not needed, the default configuration object
        //enables CallKit by default, it is here for completeness sake
        config.isCallKitEnabled = true

        //The following statement is going to change the name of the app that is going to be shown by the system call UI.
        //If you don't set this value during the configuration, the SDK will look for to the value of the
        //CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App Info.plist

        if #available(iOS 10.0, *) {
            config.nativeUILocalizedName = "My wonderful app"
        }

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

        if #available(iOS 10.0, *) {
            let callKitIcon = UIImage(named: "callkit-icon")
            config.nativeUITemplateIconImageData = callKitIcon?.pngData()
        }

        //The following statements will tell the BandyerSDK to use the app custom BCXHandleProvider. When any call is performed this
        //object will tell CallKit which is the name of the call opponent it should show on the system call UI.
        if #available(iOS 10.0, *) {
            config.supportedHandleTypes = Set(arrayLiteral: NSNumber(integerLiteral: CXHandle.HandleType.generic.rawValue))
            config.handleProvider = HandleProvider(addressBook: AddressBook.instance)
        }
        //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
#error("Please initialize the Bandyer SDK with your App Id")
        BandyerSDK.instance().initialize(withApplicationId: "PUT YOUR APP ID HERE", config: config)
        
        applyTheme()

        customizeInAppNotification()

        return true
    }
    
    private func applyTheme() {
        let accentColor = UIColor.accentColor
        
        if #available(iOS 14.0, *) {
        } else {
            window?.tintColor = accentColor
        }

        //This is the core of your customisation possibility using Bandyer SDK theme.
        //Let's suppose that your app is highly customised. Setting the following properties will let you to apply your colors, bar properties and fonts to all Bandyer's view controllers.
        
        //Colors
        BDKTheme.default().accentColor = accentColor
        BDKTheme.default().primaryBackgroundColor = UIColor.customBackground
        BDKTheme.default().secondaryBackgroundColor = UIColor.customSecondary
        BDKTheme.default().tertiaryBackgroundColor = UIColor.customTertiary
        
        //Bars
        BDKTheme.default().barTranslucent = false
        BDKTheme.default().barStyle = .black
        BDKTheme.default().keyboardAppearance = .dark
        BDKTheme.default().barTintColor = UIColor.customBarTintColor

        //Fonts
        BDKTheme.default().navBarTitleFont = UIFont.robotoMedium
        BDKTheme.default().secondaryFont = UIFont.robotoLight
        BDKTheme.default().bodyFont = UIFont.robotoThin
        BDKTheme.default().font = UIFont.robotoRegular
        BDKTheme.default().emphasisFont = UIFont.robotoBold
        BDKTheme.default().mediumFontPointSize = 15
    }

    private func customizeInAppNotification() {
        //Only after the SDK is initialized, you can change the In-app notification theme and set a custom formatter.
        //If you try to set the theme or the formatter before SDK initialization, the notificationsCoordinator will be nil and sets will not be applied.
        //The formatter will be used to display the user information on the In-app notification heading.

        let theme = BDKTheme()
        theme.secondaryFont = UIFont.robotoRegular.withSize(5)

        BandyerSDK.instance().notificationsCoordinator?.theme = theme
        BandyerSDK.instance().notificationsCoordinator?.formatter = HashtagFormatter()
    }
}
