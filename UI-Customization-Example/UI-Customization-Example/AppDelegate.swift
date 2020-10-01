//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import UIKit
import Bandyer

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

        //Here we are disabling CallKit support.
        //Make sure to disable CallKit, otherwise it will be enabled by default if the system supports CallKit (i.e iOS >= 10.0).
        config.isCallKitEnabled = false

#error("Please initialize the Bandyer SDK with your App Id")
        //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
        BandyerSDK.instance().initialize(withApplicationId: "PUT YOUR APP ID HERE", config: config)
        
        applyTheme()
        
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
}
