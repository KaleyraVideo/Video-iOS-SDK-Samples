//
//  Copyright © 2019 Bandyer. All rights reserved.
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

        return true
    }
}
