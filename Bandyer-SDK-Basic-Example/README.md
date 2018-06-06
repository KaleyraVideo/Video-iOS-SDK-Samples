# Bandyer iOS SDK Basic Example

This app is simple application meant to demonstrate the SDK capabilities and the features it provides.

## Quick Start

1. Obtain a Mobile Api Key.
2. Run `pod install`.
3. Add the user aliases obtained from the REST API in the LoginViewController and in the ContactsTableViewController.
4. Add NSCameraUsageDescription and NSMicrophoneUsageDescription keys to the app's Info.plist.
5. Run the app.

## Notes

* The application is setup to run in a sandbox environment.
* You can test the application on iOS Simulator or an a real device. However, in iOS simulator does not provide access to the camera. When running in the iOS Simulator a fake  capturer is used, which uses a demo video, instead of the camera.
