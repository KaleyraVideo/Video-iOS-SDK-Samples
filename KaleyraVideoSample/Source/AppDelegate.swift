//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit
import PushKit
import Intents
import CallKit
import KaleyraVideoSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private(set) var callDetector: VoIPCallDetector?

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
        KaleyraVideo.logLevel = .all
        do {
            let config = try AppConfig.default.makeSDKConfig()

            if !config.voip.isAutomatic {
                // If you have set the config `automaticallyHandleVoIPNotifications` to false you have to register to VoIP notifications manually.
                // This is an example of the required implementation.
                callDetector = VoIPCallDetector(registryDelegate: self)
                callDetector?.delegate = self
            }

            //Now we are ready to configure the SDK providing the configuration object previously created.
            KaleyraVideo.instance.configure(config) { _ in }

            return true
        } catch {
            return true
        }
    }

    func startCallDetectorIfNeeded() {
        callDetector?.start()
    }

}

extension AppDelegate: PKPushRegistryDelegate {

    // When the system notifies the SDK of the new VoIP push token
    // The SDK will call this method (if set this instance as pushRegistryDelegate in the config object)
    // Providing you the push token. You should send the token received to your back-end system
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        debugPrint("Push credentials updated \(pushCredentials), you should send them to your backend system")
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

        guard let startCallIntent = siriIntent as? INStartCallIntent else {
            return true
        }

        return false
    }
}

// This protocol conformance is required for the manually managed VoIP notification configuration, ignore it otherwise.
extension AppDelegate: VoIPCallDetectorDelegate {
    func handle(payload: PKPushPayload) {
        // Once you received a VoIP notification and you want the sdk to handle it, call `handleNotification(_)` method on the sdk instance.
        KaleyraVideo.instance.conference?.handleNotification(payload)
    }
}
