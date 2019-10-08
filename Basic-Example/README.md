# Bandyer SDK Basic Example

This sample app is going to show you how the Bandyer SDK should be configured, initialized, and how you can interact with it.

## Quickstart

1. Obtain a Mobile API key
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) .
3. In terminal, run the `pod install` command
4. Open the project in Xcode 
5. Add `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` keys to the app's Info.plist file
6. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
7. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.


## Caveats

This app uses fake users fetched from our backend system. We provide access to those user through a REST api which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

If your backend system already provides Bandyer "user alias" for your users, then you should modify the app in order to fetch users information from you backend system instead of ours.

## Support

To get basic support please submit an Issue

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com.)

## Credits

- Sample video file taken from https://sample-videos.com/
- Sample user profile images taken from https://randomuser.me/
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

