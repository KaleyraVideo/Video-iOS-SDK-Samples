//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI
import Bandyer

@main
struct SwiftUI_ExampleApp: App {

    @UIApplicationDelegateAdaptor static var appDelegate: AppDelegate

    init() {
        setupBandyerSDK()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .onContinueUserActivity("INStartVideoCallIntent", perform: userActivityHandler)
                .onContinueUserActivity("INStartCallIntent", perform: userActivityHandler)
        }
    }

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
    private func setupBandyerSDK() {

        // Here we are going to initialize the Bandyer SDK
        // The sdk needs a configuration object where it is specified which environment the sdk should work in.
        let config = AppConfig.default.makeSDKConfig(pushRegistryDelegate: SwiftUI_ExampleApp.appDelegate)

        if !config.automaticallyHandleVoIPNotifications {
            // If you have set the config `automaticallyHandleVoIPNotifications` to false you have to register to VoIP notifications manually.
            // This is an example of the required implementation.
            SwiftUI_ExampleApp.appDelegate.setupCallDetector()
        }

        //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
        BandyerSDK.instance().initialize(withApplicationId: Constants.AppId,
                                         config: config)
    }

    // When System call ui is shown to the user, it will show a "video" button if the call supports it.
    // The code below will handle the siri intent received from the system and it will hand it to the call view controller
    // if the controller is presented
    func userActivityHandler(_ userActivity: NSUserActivity) {
        guard let siriIntent = userActivity.interaction?.intent else {
            return
        }

        guard let window = CallWindow.instance else {
            return
        }

        if let startCallIntent = siriIntent as? INStartCallIntent {
            window.handle(startCallIntent: startCallIntent)
            return
        }

        if let videoCallIntent = siriIntent as? INStartVideoCallIntent {
            window.handle(startVideoCallIntent: videoCallIntent)
            return
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, PKPushRegistryDelegate {

    private(set) var callDetector: VoIPCallDetector?

    func setupCallDetector() {
        // If you have set the config `automaticallyHandleVoIPNotifications` to false you have to register to VoIP notifications manually.
        // This is an example of the required implementation.
        callDetector = VoIPCallDetector(registryDelegate: self)
        callDetector?.delegate = self
    }

    // When the system notifies the SDK of the new VoIP push token
    // The SDK will call this method (if set this instance as pushRegistryDelegate in the config object)
    // Providing you the push token. You should send the token received to your back-end system
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let token = pushCredentials.tokenAsString else { return }

        debugPrint("Push credentials updated \(token), you should send them to your backend system")
    }

    func startCallDetectorIfNeeded() {
        callDetector?.start()
    }
}

// This protocol conformance is required for the manually managed VoIP notification configuration, ignore it otherwise.
extension AppDelegate: VoIPCallDetectorDelegate {
    func handle(payload: PKPushPayload) {
        // Once you received a VoIP notification and you want the sdk to handle it, call `handleNotification(_)` method on the sdk instance.
        BandyerSDK.instance().handleNotification(payload)
    }
}
