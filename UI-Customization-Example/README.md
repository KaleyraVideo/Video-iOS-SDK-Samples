# Bandyer SDK UI Customization Example

This sample app is going to show you how the Bandyer SDK can be configured in order for you to customise the UI components provided by the SDK.

For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift).

## Quickstart

1. Obtain a Mobile API key.
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) .
3. In terminal, `cd` to the sample project directory you are interested in and type `pod install`.
4. Open the project in Xcode using the `.xcworkspace` file just created.
5. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
6. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.

## Caveats

This app uses fake users fetched from our backend system. We provide access to those users through a REST API which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

If your backend system already provides Bandyer "user alias" for your users, then you should modify the app in order to fetch users information from you backend system instead of ours.

## Usage

In this demo app, all the integration work is already done for you. In this section we will explain how to take advantage of the feature provided by Bandyer SDK in another app.

### Setup

To let you build on physical devices, you should set *No* to  *Enable Bitcode* on **Build Settings** tab under **Build Options** section of your target settings.

To initialize our SDK, start the call and chat modules and push the Bandyer View Controllers please refer to related [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki) pages. 

### Global UI theme

The core of customization is [BDKTheme](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKTheme.html) class. You can override every property of the theme, typically inside your AppDelegate implementation.

```swift
//This is the core of your customisation possibility using Bandyer SDK theme.
//Let's suppose that your app is highly customised. Setting the following properties will let you to apply your colors, bar properties and fonts to all Bandyer's view controllers.
        
//Colors
BDKTheme.default().accentColor = a UIColor instance
BDKTheme.default().primaryBackgroundColor = a UIColor instance
BDKTheme.default().secondaryBackgroundColor = a UIColor instance
BDKTheme.default().tertiaryBackgroundColor = a UIColor instance
        
//Bars
BDKTheme.default().barTranslucent = true/false
BDKTheme.default().barStyle = a UIBarStyle case
BDKTheme.default().keyboardAppearance = a UIKeyboardAppearance case
BDKTheme.default().barTintColor = a UIColor instance

//Fonts
BDKTheme.default().navBarTitleFont = a UIFont instance
BDKTheme.default().secondaryFont = a UIFont instance 
BDKTheme.default().bodyFont = a UIFont instance
BDKTheme.default().font = a UIFont instance
BDKTheme.default().emphasisFont = a UIFont instance
BDKTheme.default().mediumFontPointSize = a CGFloat
BDKTheme.default().largeFontPointSize = a CGFloat
```

We strongly recommend you to read the [UI-customization](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki/UI-customization) wiki page to have a look for the mapping between those properties and the UI components. 

### Call related UI theme

You can also customize every Bandyer view controller using the appropriate configuration object. For the call related view controllers you have to set the BDKTheme kind properties of [CallViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKCallViewControllerConfiguration.html):

```swift
let config = CallViewControllerConfiguration()
 
//Let's suppose that you want to change the navBarTitleFont only inside the BDKCallViewController.
//You can achieve this result by allocate a new instance of the theme and set the navBarTitleFont property whit the wanted value.
let callTheme = BDKTheme()
callTheme.navBarTitleFont = UIFont.robotoBold.withSize(30)

config.callTheme = callTheme

//The same reasoning will let you change the accentColor only inside the Whiteboard view controller.
let whiteboardTheme = BDKTheme()
whiteboardTheme.accentColor = UIColor.systemBlue

config.whiteboardTheme = whiteboardTheme

//You can also customize the theme only of the Whiteboard text editor view controller.
let whiteboardTextEditorTheme = BDKTheme()
whiteboardTextEditorTheme.bodyFont = UIFont.robotoThin.withSize(30)

config.whiteboardTextEditorTheme = whiteboardTextEditorTheme

//In the next lines you can see how it's possible to customize the File Sharing view controller theme.
let fileSharingTheme = BDKTheme()
//By setting a point size property of the theme you can change the point size of all the medium/large labels.
fileSharingTheme.mediumFontPointSize = 20
fileSharingTheme.largeFontPointSize = 40

config.fileSharingTheme = fileSharingTheme
```

### Chat channel UI theme

It's also easy to customize the [ChannelViewController](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/ChannelViewController.html) using the [ChannelViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/ChannelViewControllerConfiguration.html) class. You just have to init the class passing the BDKTheme object as initialization parameter.

```swift
//Let's suppose that you want to change the tertiaryBackgroundColor only inside the ChannelViewController.
//You can achieve this result by allocate a new instance of the theme and set the tertiaryBackgroundColor property whit the wanted value.
let theme = BDKTheme()
theme.tertiaryBackgroundColor = UIColor(red: 204/255, green: 210/255, blue: 226/255, alpha: 1)

let configuration = ChannelViewControllerConfiguration(audioButton: true, videoButton: true, theme: theme)
    
channelViewController.configuration = configuration
```

### In-app notification UI theme

In the next code snippet you can find an example of how to customize the theme of our In-app notification view.

```swift
//Only after the SDK is initialized, you can change the In-app notification theme. 
//If you try to set the theme before SDK initialization, the notificationsCoordinator will be nil and your theme will not be applied. 
let theme = BDKTheme()
theme.secondaryFont = UIFont.robotoRegular.withSize(5)

BandyerSDK.instance().notificationsCoordinator?.theme = theme
```
### Formatters

With our SDK you can decide how the user information are displayed on the screen. You just need to subclass the [Formatter](https://developer.apple.com/documentation/foundation/formatter) class and implement the `func string(for: Any?) -> String?` casting the Any object to an array of 
[BDKUserInfoDisplayItem](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKUserInfoDisplayItem.html).

In the next code snippets you will see how to use your custom formatters. 

You can format the way our SDK displays the user information inside the call page:

```swift
//In this example, the user info will be preceded by a percentage.
let config = CallViewControllerConfiguration()
config.callInfoTitleFormatter = PercentageFormatter()
```

You can do the same for the chat channel page:

```swift
//In this example, the user info will be preceded by an asterisk.
let configuration = ChannelViewControllerConfiguration(audioButton: true, videoButton: true, formatter: AsteriskFormatter())
```

Only after the SDK is initialized, you can change the In-app notification default formatter. 
If you try to set the formatter before SDK initialization, the notificationsCoordinator will be nil and your custom formatter will not be applied. 
The formatter will be used to display the user information on the In-app notification heading.

```swift
//In this example, the user info will be preceded by an hashtag.
BandyerSDK.instance().notificationsCoordinator?.formatter = HashtagFormatter()
```

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easily find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com).

## Credits

- Sample video file taken from [Sample Videos](https://sample-videos.com/).
- Sample user profile images taken from [RANDOM USER GENERATOR](https://randomuser.me/).
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.
- Custom font 'Roboto' is taken from [dafont.com](https://www.dafont.com/it/roboto.font).

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift/blob/master/LICENSE) file.
