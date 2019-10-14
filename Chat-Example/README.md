# Bandyer SDK Chat Example

This sample app is going to show you how the Bandyer SDK should be configured, initialized, and how you can interact with it.

This example is only related to let users make and receive messages from the chat service. For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift).

## Quickstart

1. Obtain a Mobile API key.
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) .
3. In terminal, `cd` to the sample project directory you are interested in and type `pod install`.
4. Open the project in Xcode using the `.xcworkspace` file just created.
5. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
6. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.

## Caveats

This app uses fake users fetched from our backend system. We provide access to those user through a REST api which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

If your backend system already provides Bandyer "user alias" for your users, then you should modify the app in order to fetch users information from you backend system instead of ours.

## Usage

In this demo app, all the integration work is already done for you. In this section we will explain how to take advantage of the feature provided by Bandyer SDK in another app.

### Initialization

First of all you have to initialize the SDK using the unique instance of [BandyerSDK](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BandyerSDK.html) and configure it using [BDKConfig](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BDKConfig.html) class. Yuo can follow this code snippet:

```swift
//Here we are going to initialize the Bandyer SDK.
//The sdk needs a configuration object where it is specified which environment the sdk should work in.
let config = BDKConfig()

//Here we are telling the SDK we want to work in a sandbox environment.
//Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
config.environment = .sandbox

//Here we are disabling CallKit support.
//Make sure to disable CallKit, otherwise it will be enable by default if the system supports CallKit (i.e iOS >= 10.0).
config.isCallKitEnabled = false
        
//Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
BandyerSDK.instance().initialize(withApplicationId: "PUT YOUR APP ID HERE", config: config)
```
In the demo project, we did it inside `AppDelegate` class, but you can do everywhere you need, just before using our SDK.

### SDK Start

Once the end user has selected which user wants to impersonate, you have to start the SDK client. 

We did it inside the `LoginViewController` class.

```swift
//We are registering as a chat client observer in order to be notified when the client changes its state.
//We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
//otherwise the SDK will notify the observer onto its background internal queue.
BandyerSDK.instance().chatClient.add(observer: self, queue: .main)

//Here we start the chat client, providing the "user alias" of the user selected.
BandyerSDK.instance().chatClient.start(userId:"SELECTED USER ID")
```
Your class responsible of starting the client has the possibility to become an observer of the [BCHChatClient](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BCHChatClient.html) lifecycle, implementing the [BCHChatClientObserver](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BCHChatClientObserver.html). Once the `chatClientDidStart` callback is fired, you can start to interact with our system.

### Start a chat

In order to make a call, we provide you a custom `UIViewController`: the [ChannelViewController](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/ChannelViewController.html).

Inside the `ContactsViewController` class you can find some code snippet on how to manage initialization of a ChannelViewController instance. 

When you want to start a new chat session, you need to configure the ChannelViewController instance with a [ChannelViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/ChannelViewControllerConfiguration.html), passing to it your implementation of [BDKUserInfoFetcher](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BDKUserInfoFetcher.html) protocol. This protocol is intended to manage your custom formatting of an user instance. The ChannelViewController will use this fetcher to properly present contact information in its views. For further information on how it works, please have a look to our [sample app](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift/tree/master/UserInfoFetcher-Example) related to this argument. 

```swift
let channelViewController = ChannelViewController()
channelViewController.delegate = self

//Here we are configuring the channel view controller:
// if audioButton is true, the channel view controller will show audio button on nav bar;
// if videoButton is true, the channel view controller will show video button on nav bar;
// if userInfoFetcher is set, the global userInfoFetcher will be overridden. WARNING!!!

let userInfoFetcher = UserInfoFetcher(addressBook!)

//Here if we pass a nil userInfoFetcher, the Bandyer SDK will use the global one if set at initialization time, otherwise a default one. The same result is achieved without setting the configuration property.
let configuration = ChannelViewControllerConfiguration(audioButton: true, videoButton: true, userInfoFetcher: userInfoFetcher)

//Otherwise you can use other initializer.
//let configuration = ChannelViewControllerConfiguration() //Equivalent to ChannelViewControllerConfiguration(audioButton: false, videoButton: false, userInfoFetcher: nil)

//If no configuration is provided, the default one will be used, the one with nil user info fetcher and showing both of the buttons -> ChannelViewControllerConfiguration(audioButton: true, videoButton: true, userInfoFetcher: nil)
channelViewController.configuration = configuration
```

Once the ChannelViewController is properly configured, you have to pass an instance of [OpenChatIntent](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/OpenChatIntent.html) to the it. You can open the chat controller directly with the counterpart id or from a `ChatNotification` instance.

```swift
let intent = OpenChatIntent.openChat(with: "Counterpart ID")
```

```swift
let notification: ChatNotification
let intent = OpenChatIntent.openChat(from: notification)
```

```swift
//Please make sure to set intent after configuration, otherwise the configuration will be not taking in charge.
channelViewController.intent = intent
```
Finally, you can present the ChannelViewController.

```swift
controller.present(channelViewController, animated: true)
```

### Message Notification View

When your logged user receives a chat message, your view controller can show a custom `UIView` at the top of the screen. This view acts like a in-app notification, so user can click it to open the chat or can dismiss it just swiping to the top.

Yuo don't have to manage by yourself the behaviour of the notification view, inside the SDK you can find the [MessageNotificationController](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/MessageNotificationController.html) that does the job for you.

You can easily init the controller using this code snippet:

```swift
let messageNotificationController = MessageNotificationController()
```

Once inited, you have to setup the controller, attaching the delegate and the view controller. If you don't pass the parentViewController an exception will be thrown, since the  notification controller needs it to add the notification view to your view hierarchy.

```swift
//WARNING!!! If userInfoFetcher is set, the global userInfoFetcher will be overridden.
let userInfoFetcher = UserInfoFetcher(addressBook!)

//Here if we pass a nil userInfoFetcher, the Bandyer SDK will use the global one if set at initialization time, otherwise a default one. The same result is achieved without setting the configuration property.
let configuration = MessageNotificationControllerConfiguration(userInfoFetcher: userInfoFetcher)
messageNotificationController.configuration = configuration

messageNotificationController.delegate = self
messageNotificationController.parentViewController = self
```

When your view controller is hidden you have to tell the notification controller to stop work on your view controller. You can achieve this result using the `show` and `hide` methods:

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        
    messageNotificationController.show()
}
 
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
        
    messageNotificationController.hide()
} 
```

Since the size of the notification view changes with orientation, you have to update the UI of the view:

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    //Remember to call viewWillTransitionTo on custom view controller to update UI while rotating.
    messageNotificationController.viewWillTransition(to: size, withTransitionCoordinator: coordinator)
        
    super.viewWillTransition(to: size, with: coordinator)
}
```

On `ContactsViewController` class you can find all this code snippets working and commented, plus more (like the management of transition between `ChatNotification` and `ChannelViewController`).

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easily find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com.)

## Credits

- Sample video file taken from [Sample Videos](https://sample-videos.com/).
- Sample user profile images taken from [RANDOM USER GENERATOR](https://randomuser.me/).
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift/blob/master/LICENSE) file.
