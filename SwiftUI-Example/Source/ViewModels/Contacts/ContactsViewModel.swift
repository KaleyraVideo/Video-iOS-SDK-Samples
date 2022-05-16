//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer
import Combine
import SwiftUI

class ContactsViewModel: NSObject, ObservableObject {

    enum CallType {
        case call
        case conference
    }

    @Published private(set) var userInteractionEnabled = true

    private var addressBook: AddressBook?
    @Published var desiredCallType = CallType.call
    @Published var selectedContacts = Set<Contact>()
    @Published var multipleSelectionEnabled = false
    @Published private(set) var canCallManyToMany = false
    private var callTypeObserver: AnyCancellable?
    private var selectedUsersObserver: AnyCancellable?

    @Published var showingAlert: Bool = false
    @Published var showingChat: Bool = false
    @Published var hideToastView: Bool = true

    private(set) var options = CallOptionsItem()

    private(set) var alertToPresent: (title: String, message: String)? {
        didSet {
            showingAlert = alertToPresent != nil
        }
    }

    private(set) var chatViewToPresent: ChatViewControllerWrapper? {
        didSet {
            showingChat = chatViewToPresent != nil
        }
    }

    @Published private(set) var toastToPresent: String = "" {
        didSet {
            hideToastView = toastToPresent.isEmpty
        }
    }

    private var intent: Intent?
    private var callWindow: CallWindow?

    var contacts: [Contact] {
        addressBook?.contacts ?? []
    }

    var loggedUserID: String {
        addressBook?.me?.userID ?? ""
    }

    // MARK: - Initialization

    init(addressBook: AddressBook?) {
        self.addressBook = addressBook

        super.init()

        attachCallTypeChangeObservers()

        setupCallClientObserver()
    }
    
    // MARK: - Setup

    private func attachCallTypeChangeObservers() {
        callTypeObserver = $desiredCallType.sink { [weak self] newVal in
            self?.multipleSelectionEnabled = newVal == .conference
        }

        selectedUsersObserver = $selectedContacts.sink(receiveValue: { [weak self] contacts in
            self?.canCallManyToMany = contacts.count >= 2
        })
    }

    private func setupCallClientObserver() {
        // When view loads we register as a client observer, in order to receive notifications about received incoming calls and client state changes.
        BandyerSDK.instance.callClient.add(observer: self, queue: .main)
        BandyerSDK.instance.callClient.addIncomingCall(observer: self, queue: .main)
    }

    // MARK: - View appearing events

    func viewAppeared() {
        setupNotificationsCoordinator()
    }

    func viewDisappeared() {
        disableNotificationsCoordinator()
    }

    // MARK: - In-app Notifications

    private func setupNotificationsCoordinator() {
        BandyerSDK.instance.notificationsCoordinator?.chatListener = self
        BandyerSDK.instance.notificationsCoordinator?.fileShareListener = self
        BandyerSDK.instance.notificationsCoordinator?.start()
    }

    private func disableNotificationsCoordinator() {
        BandyerSDK.instance.notificationsCoordinator?.stop()
    }

    private func presentAlert(title: String, message: String) {
        alertToPresent = (title: title, message: message)
    }

    func logout() {
        UserSession.currentUser = nil
        BandyerSDK.instance.disconnect()
    }

    // MARK: - Call

    func call(user: Contact) {
        selectedContacts.removeAll()
        selectedContacts.insert(user)

        startOutgoingCall()
    }

    func callSelectedUsers() {
        guard canCallManyToMany else { return }

        startOutgoingCall()
    }

    private func receiveIncomingCall(call: Call) {
        // When the client detects an incoming call it will notify its observers through this method.
        // Here we are creating an `HandleIncomingCallIntent` object, storing it for later use,
        // then we trigger a presentation of CallViewController.
        intent = HandleIncomingCallIntent(call: call)
        performCallViewControllerPresentation()
    }

    private func startOutgoingCall() {
        // To start an outgoing call we must create a `StartOutgoingCallIntent` object specifying who we want to call,
        // the type of call we want to be performed, along with any call option.

        // Here we create the array containing the "user IDs" we want to contact.
        let userIDs = selectedContacts.compactMap({ $0.userID })

        // Then we create the intent providing the user IDs array (which is a required parameter) along with the type of call we want perform.
        // The record flag specifies whether we want the call to be recorded or not.
        // The maximumDuration parameter specifies how long the call can last.
        // If you provide 0, the call will be created without a maximum duration value.
        // We store the intent for later use, because we can present again the CallViewController with the same call.
        intent = StartOutgoingCallIntent(callees: userIDs,
                                         options: CallOptions(callType: options.type,
                                                              recordingType: options.recordingType,
                                                              duration: options.maximumDuration))

        // Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    // MARK: - Chat ViewController

    func openChat(with contact: Contact) {
        let chatIntent = OpenChatIntent.openChat(with: contact.userID)
        presentChat(from: chatIntent)
    }

    private func presentChat(from notification: ChatNotification) {
        guard let intent = OpenChatIntent.openChat(from: notification) else {
            return
        }
        presentChat(from: intent)
    }

    private func presentChat(from intent: OpenChatIntent) {
        var chatViewControllerWrapper = ChatViewControllerWrapper()
        chatViewControllerWrapper.delegate = self
        chatViewControllerWrapper.intent = intent

        chatViewToPresent = chatViewControllerWrapper
    }

    private func dismissChat() {
        chatViewToPresent = nil
    }

    // MARK: - Call ViewController

    private func performCallViewControllerPresentation() {
        guard let intent = self.intent else { return }

        prepareForCallViewControllerPresentation()

        // Here we tell the call window to present the Call UI if there is not another call in progress.
        // Otherwise you should handle the error notified as the closure argument.

        callWindow?.presentCallViewController(for: intent) { [weak self] error in
            guard let _ = error else { return }
            guard let self = self else { return }

            self.presentAlert(title: "Error", message: "Impossible to start a call now. Try again later.")
        }
    }

    private func prepareForCallViewControllerPresentation() {
        initCallWindowIfNeeded()

        let filePath = Bundle.main.path(forResource: "SampleVideo_640x360_10mb", ofType: "mp4")

        guard let path = filePath else {
            fatalError("The fake file for the file capturer could not be found")
        }

        // This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
        let url = URL(fileURLWithPath: path)

        // Here we are configuring the CallViewController instance.
        // A `CallViewControllerConfiguration` object instance is needed to customize the behavior and appearance of the view controller.
        // You can create an instance of CallViewControllerConfiguration class through a CallViewControllerConfigurationBuilder object as below.
        let builder = CallViewControllerConfigurationBuilder()
            .withFakeCapturerFileURL(url)
        
        let customizeUI = false

        if customizeUI {
            //Comment this line to disable the call feedback popup
            _ = builder.withFeedbackEnabled()

            //Let's suppose that you want to change the navBarTitleFont only inside the BDKCallViewController.
            //You can achieve this result by allocate a new instance of the theme and set the navBarTitleFont property whit the wanted value.
            let callTheme = Theme()
            callTheme.navBarTitleFont = .robotoBold.withSize(30)

            _ = builder.withCallTheme(callTheme)

            //The same reasoning will let you change the accentColor only inside the Whiteboard view controller.
            let whiteboardTheme = Theme()
            whiteboardTheme.accentColor = .systemBlue

            _ = builder.withWhiteboardTheme(whiteboardTheme)

            //You can also customize the theme only of the Whiteboard text editor view controller.
            let whiteboardTextEditorTheme = Theme()
            whiteboardTextEditorTheme.bodyFont = .robotoThin.withSize(30)

            _ = builder.withWhiteboardTextEditorTheme(whiteboardTextEditorTheme)

            //In the next lines you can see how it's possible to customize the File Sharing view controller theme.
            let fileSharingTheme = Theme()
            //By setting a point size property of the theme you can change the point size of all the medium/large labels.
            fileSharingTheme.mediumFontPointSize = 20
            fileSharingTheme.largeFontPointSize = 40

            _ = builder.withFileSharingTheme(fileSharingTheme)

            // In the same way as other themes, you can customize the appearance of the call feedback popup by creating a new instance of Theme
            let feedbackTheme = Theme()
            // Setting the accentColor property with the desired value will modify the color of the stars and the background color of the submit button
            feedbackTheme.accentColor = .systemGreen
            // You can also customize the font and emphasisFont properties
            feedbackTheme.font = .robotoThin
            feedbackTheme.emphasisFont = .robotoBold

            // The delay in seconds after which the feedback popup is automatically dismissed when the user leaves a feedback.
            _ = builder.withFeedbackEnabled(theme: feedbackTheme, autoDismissDelay: 5)

            // Every single string in the feedback popup is customizable.
            // To make this customization just pass the bundle containing the localization with the right keys valorized, as in this example.
            // If your file is named 'Localizable' you don't need to set the TableName value, otherwise provide the filename
            _ = builder.withCustomLocalizations(bundle: .main, tableName: "ExampleLocalizable")

            //You can also format the way our SDK displays the user information inside the call page. In this example, the user info will be preceded by a percentage.
            _ = builder.withCallInfoTitleFormatter(PercentageFormatter())
        }

        // Here, we set the configuration object created. You must set the view controller configuration object before the view controller
        // view is loaded, otherwise an exception is thrown.
        callWindow?.setConfiguration(builder.build())
    }

    private func initCallWindowIfNeeded() {
        // Please remember to reference the call window only once in order to avoid the reset of CallViewController.
        guard callWindow == nil else { return }

        // Please be sure to have in memory only one instance of CallWindow, otherwise an exception will be thrown.
        let window: CallWindow

        if let instance = CallWindow.instance {
            window = instance
        } else {
            // This will automatically save the new instance inside CallWindow.instance.
            window = CallWindow()
        }

        // Remember to subscribe as the delegate of the window. The window  will notify its delegate when it has finished its job.
        window.callDelegate = self

        callWindow = window
    }

    private func hideCallViewController() {
        callWindow?.isHidden = true
    }

    // MARK: - Toast

    func showToast(message: String) {
        toastToPresent = message
    }

    func hideToast() {
        toastToPresent = ""
    }
}

// MARK: - Call client observer

extension ContactsViewModel: CallClientObserver {

    func callClientWillChangeState(_ client: CallClient, oldState: CallClientState, newState: CallClientState) {
        if newState == .resuming {
            callClientWillResume()
        }
    }

    func callClientDidChangeState(_ client: CallClient, oldState: CallClientState, newState: CallClientState) {
        if newState == .running {
            callClientDidStart()
        }
        else if newState == .reconnecting {
            callClientDidStartReconnecting()
        }
    }

    private func callClientDidStart() {
        userInteractionEnabled = true
        hideToast()
    }

    private func callClientDidStartReconnecting() {
        userInteractionEnabled = false
        showToast(message: "Client is reconnecting, please wait...")
    }

    private func callClientWillResume() {
        userInteractionEnabled = false
        showToast(message: "Client is resuming, please wait...")
    }
}

// MARK: - IncomingCallObserver

extension ContactsViewModel: IncomingCallObserver {

    func callClient(_ client: CallClient, didReceiveIncomingCall call: Call) {
        receiveIncomingCall(call: call)
    }
}

// MARK: - Call window delegate

extension ContactsViewModel: CallWindowDelegate {

    func callWindowDidFinish(_ window: CallWindow) {
        hideCallViewController()
    }

    func callWindow(_ window: CallWindow, openChatWith intent: OpenChatIntent) {
        presentChat(from: intent)
    }
}

//MARK: Channel view controller delegate

extension ContactsViewModel: ChannelViewControllerDelegate {

    func channelViewControllerDidFinish(_ controller: ChannelViewController) {
        dismissChat()
    }

    func channelViewController(_ controller: ChannelViewController, didTapAudioCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioUpgradable)
    }

    func channelViewController(_ controller: ChannelViewController, didTapVideoCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioVideo)
    }

    private func dismiss(channelViewController: ChannelViewController, presentCallViewControllerWith callees: [String], type: Bandyer.CallType) {
        dismissChat()

        intent = StartOutgoingCallIntent(callees: callees, options: CallOptions(callType: type))
        performCallViewControllerPresentation()
    }
}

// MARK: - In App file share notification touch listener delegate

extension ContactsViewModel: InAppChatNotificationTouchListener {
    
    func onTouch(_ notification: ChatNotification) {
        dismissChat()
        presentChat(from: notification)
    }
}

// MARK: - In App file share notification touch listener delegate

extension ContactsViewModel: InAppFileShareNotificationTouchListener {

    func onTouch(_ notification: FileShareNotification) {
        callWindow?.presentCallViewController(for: OpenDownloadsIntent())
    }
}
