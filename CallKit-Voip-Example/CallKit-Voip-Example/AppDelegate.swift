//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import UIKit
import PushKit
import BandyerSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var registry: PKPushRegistry?
    var pendingPayload: PKPushPayload?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Before we can get started, you must review your project configuration, and enable the required
        //app capabilities for CallKit and Voip notifications.
        //
        //Namely, you must enable "Background modes" capability
        //checking "Audio, AirPlay and Picture in Picture" and "Voice over IP" checkboxes on.
        //You must also enable "Push notifications" capability even if you use VOIP notifications only.
        //
        //Privacy usage descriptions:
        //You must add NSCameraUsageDescription and NSMicrophoneUsageDescription to your app Info.plist file.
        //Those values are required to access microphone and camera. In this example app, those values have been already added for you
        //
        //CallKit:
        //CallKit framework must be linked to your app and it must linked as a required framework,
        //otherwise the app will have a weird behaviour when it is launched upon receiving a voip notification.
        //It is going to be launched, but the system is going to suspend it after few milliseconds.
        //In this example app, the CallKit framework has been already added for you.
        //Please check the project "Build Settings" tab under the "Other Linker Flags" directive that the CallKit
        //framework is linked as required framework
        
        //Here we are going to initialize the Bandyer SDK
        //The sdk needs a configuration object where it is specified which environment the sdk should work in
        let config = BDKConfig()
        
        //Here we are telling the SDK we want to work in a sandbox environment.
        //Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
        config.environment = BDKEnvironment.sandbox
        
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
        
        //config.nativeUIRingToneSound = @"MyRingtoneSound";
        
        //The following statements are going to change the app icon shown in the system call UI. When the user answers
        //a call from the lock screen or when the app is not in foreground and a call is in progress, the system
        //presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
        //app. The following statements allows you to change that icon.
        //Beware, the configuration object property expects the image as an NSData object. You must provide a side
        //length 40 points square png image.
        //It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.
        
        let callKitIcon = UIImage(named: "callkit-icon")
        config.nativeUITemplateIconImageData = callKitIcon?.pngData()

        //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
        BandyerSDK.instance().initialize(withApplicationId: "YOUR_APP_ID", config: config)

        //We subscribe to the call client in order to be informed when the client is ready to handle notifications payload
        BandyerSDK.instance().callClient.add(self, queue: DispatchQueue.main)
        
        //Here we are initializing the push kit registry
        registry = PKPushRegistry(queue: DispatchQueue.main)
        registry?.delegate = self
        registry?.desiredPushTypes = [.voIP]
        
        return true
    }
    
    func handlePushPayload(_ payload:PKPushPayload?){
        
        guard let p = payload else {
            return
        }
        
        
        let dictionaryPayload = p.dictionaryPayload as NSDictionary
        
        //You must change the keypath otherwise notifications won't be handled by the sdk
        let incomingCallPayload = dictionaryPayload.value(forKey: "KEYPATH_TO_DATA_DICTIONARY") as! [AnyHashable : Any]
        
        //We ask the client to handle the notification payload
        BandyerSDK.instance().callClient.handleNotification(incomingCallPayload)

        //If everything went fine, client observers `callClient:didReceiveIncomingCall:` method will get invoked
    }
}

extension AppDelegate : PKPushRegistryDelegate{
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        debugPrint("Push credentials updated \(token), you should send them to your backend system")
    }

    //Beware! starting from iOS 12 this method is being deprecated. However, you should not implement the new method
    //(the one with the completion closure... https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry)
    //otherwise you are not going to be able to receive incoming calls when the app is started
    //from background or has moved to background. This issue will be resolved in an upcoming SDK release.
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        switch BandyerSDK.instance().callClient.state {
        case .running:
            //If the client is running we hand it the push payload
            handlePushPayload(payload)
        case .paused:
            //Otherwise if the client is paused we first resume it and when it will notify us it has resumed we hand it
            //the notification payload
            pendingPayload = payload
            BandyerSDK.instance().callClient.resume()
            
            //Beware, if the client is stopped you must first start it and then only when it notifies it has started
            //you can hand it the notification payload. In this sample app we are going to start the client in the
            //Login view controller. The login view controller will be presented even if the app is started in background
        default:
            pendingPayload = payload
        }
    }
}

extension AppDelegate : BCXCallClientObserver{
    
    public func callClientDidStart(_ client: BCXCallClient) {
        guard pendingPayload != nil else{
            return
        }
        
        handlePushPayload(pendingPayload)
        pendingPayload = nil
    }
    
    public func callClientDidResume(_ client: BCXCallClient) {
        guard pendingPayload != nil else{
            return
        }
        
        handlePushPayload(pendingPayload)
        pendingPayload = nil
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        //When System call ui is shown to the user, it will show a "video" button if the call supports it.
        //The code below will handle the siri intent received from the system and it will hand it to the call view controller
        //if the controller is presented
        
        if userActivity.interaction?.intent is INStartVideoCallIntent{
            let vc = self.visibleController(window?.rootViewController)
            
            if vc is BDKCallViewController{
                let callController = vc! as! BDKCallViewController
                callController.handle(userActivity.interaction?.intent as! INStartVideoCallIntent)
                return true
            }
        }
        
        return false
    }
    
    func visibleController(_ controller:UIViewController?) -> UIViewController? {
        
        guard let visibleVC = controller else {
            return nil
        }
        
        if visibleVC.presentedViewController != nil{
            if visibleVC.presentedViewController is UINavigationController {
                let navController = visibleVC.presentedViewController as! UINavigationController
                return visibleController(navController.viewControllers.last)
            }
            
            return visibleController(visibleVC.presentedViewController)
        }
        
        return visibleVC
    }
}
