# Bandyer SDK CallKit - VoIP Sample

This sample application shows you how it's easy and simple to integrate CallKit and VoIP notifications capabilities with Bandyer in your app.

This example is only related to manage CallKit and VoIP notifications. For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift).

## Quickstart

1. Obtain a Mobile API key.
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started).
3. In terminal, run the `pod install` command.
4. Open the project workspace in Xcode.
5. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
6. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.
7. Replace "SET YOUR PAYLOAD KEY PATH HERE" key-path placeholder in `notificationPayloadKeyPath` property of configuration class.

## Caveats

This app uses fake users fetched from our backend system. We provide access to those user through a REST api which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

Bandyer back-end system does not deliver notifications to APNS directly, you must setup your own delivery service or use an online service like [OneSignal](https://onesignal.com/). 

## Usage

In this demo app, all the integration work is already done for you. In this section we will explain how to take advantage of the feature provided by Bandyer SDK in another app.

### Setup

Before we dive into the details of how the SDK must be configured and initialized, you should add `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` keys into app Info.plist, otherwise your app is going to crash anytime it tries to access camera
or microphone devices.

To let you build on physical devices, you should set *No* to  *Enable Bitcode* on **Build Settings** tab under **Build Options** section of your target settings. 

You must review your project configuration, and enable the required app capabilities for CallKit and VoIP notifications.
Namely,  you must update your application capabilities turning on **Background Modes** and **Push Notifications** in your project **Capabilities** tab in Xcode. Flag `Audio, Airplay and Picture in Picture` and `Voice over IP` checkboxes on, under **Background modes** section.

**CallKit** framework must be linked to your app and it must linked as a required framework, otherwise the app will have a weird behaviour when it is launched upon receiving a VoIP notification. It is going to be launched, but the system is going to suspend it after few milliseconds.

### Initialization

First of all you have to initialize the SDK using the unique instance of [BandyerSDK](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BandyerSDK.html) and configure it using [BDKConfig](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BDKConfig.html) class. Yuo can follow this code snippet:

```swift
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
//CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App 'Info.plist'.
config.nativeUILocalizedName = "My wonderful app"

//The following statement is going to change the ringtone used by the system call UI when an incoming call
//is received. You should provide the name of the sound resource in the app bundle that is going to be used as
//ringtone. If you don't set this value, the SDK will use the default system ringtone.
config.nativeUIRingToneSound = "MyRingtoneSound"

//The following statements are going to change the app icon shown in the system call UI. When the user answers
//a call from the lock screen or when the app is not in foreground and a call is in progress, the system
//presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
//app. The following statements allows you to change that icon.
//Beware, the configuration object property expects the image as an NSData object. You must provide a side
//length 40 points square png image.
//It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.

let callKitIcon = UIImage(named: "callkit-icon")
config.nativeUITemplateIconImageData = callKitIcon?.pngData()

//The following statement is going to tell the BandyerSDK which object it must forward device push tokens to when one is received.
config.pushRegistryDelegate = self

//This statement is going to tell the BandyerSDK where to look for incoming call information within the VoIP push notifications it receives.
config.notificationPayloadKeyPath = "SET YOUR PAYLOAD KEY PATH HERE"

//Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
BandyerSDK.instance().initialize(withApplicationId: "PUT YOUR APP ID HERE", config: config)

```
In the demo project, we did it inside `AppDelegate` class, but you can do everywhere you need, just before using our SDK.


#### Notification Payload

The client SDK expects a payload in the following format:

```JSON
{
    "initiator": "usr_e39b045f215f",
    "users": [
      {
        "user": {
          "companyId": "4bf3fe3d-7775-422a-9463-93554a60d2c2",
          "userAlias": "usr_a12f412g31c9",
          "firstName": "",
          "lastName": "",
          "email": null,
          "image": "",
          "role": 80,
          "status": "online",
          "canVideo": true
        },
        "status": "invited"
      },
      {
        "user": {
          "companyId": "4bf3fe3d-7775-422a-9463-93554a60d2c2",
          "userAlias": "usr_e39b045f215f",
          "firstName": "",
          "lastName": "",
          "email": "",
          "image": "",
          "role": 80,
          "status": "online",
          "canVideo": true
        },
        "status": "invited"
      }
    ],
    "roomAlias": "room_d86dc2065fd5",
    "options": {
      "duration": 0,
      "record": false,
      "creationDate": "2019-01-14T15:49:38.752Z",
      "callType": "audio_video"
    }
}

```

For further usage guideline, you can visit our dedicated [Wiki page](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki/VOIP-notifications).

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easily find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com).

## Credits

- Sample video file taken from [Sample Videos](https://sample-videos.com/).
- Sample user profile images taken from [RANDOM USER GENERATOR](https://randomuser.me/).
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift/blob/master/LICENSE) file.
