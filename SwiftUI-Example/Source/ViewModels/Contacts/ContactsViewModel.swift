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

    private var addressBook: AddressBook?
    @Published var desiredCallType = CallType.call
    @Published var selectedContacts = Set<Contact>()
    @Published var multipleSelectionEnabled = false
    @Published private(set) var canCallManyToMany = false
    private var callTypeObserver: AnyCancellable?
    private var selectedUsersObserver: AnyCancellable?

    @Published var alertPresenter = AlertPresenter()
    @Published var chatPresenter = ChatPresenter()

    private var intent: Intent?
    private var callWindow: CallWindow?

    var contacts: [Contact] {
        addressBook?.contacts ?? []
    }

    var loggedUserAlias: String {
        addressBook?.me?.alias ?? ""
    }

    init(addressBook: AddressBook?) {
        self.addressBook = addressBook

        super.init()

        attachCallTypeChangeObservers()
    }

    private func attachCallTypeChangeObservers() {
        callTypeObserver = $desiredCallType.sink { [weak self] newVal in
            self?.multipleSelectionEnabled = newVal == .conference
        }

        selectedUsersObserver = $selectedContacts.sink(receiveValue: { [weak self] contacts in
            self?.canCallManyToMany = contacts.count >= 2
        })
    }

    func logout() {
        UserSession.currentUser = nil
        BandyerSDK.instance().closeSession()
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

    private func startOutgoingCall() {
        // To start an outgoing call we must create a `StartOutgoingCallIntent` object specifying who we want to call,
        // the type of call we want to be performed, along with any call option.

        // Here we create the array containing the "user aliases" we want to contact.
        let aliases = selectedContacts.compactMap({ $0.alias })

        // Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
        // The record flag specifies whether we want the call to be recorded or not.
        // The maximumDuration parameter specifies how long the call can last.
        // If you provide 0, the call will be created without a maximum duration value.
        // We store the intent for later use, because we can present again the CallViewController with the same call.
        intent = StartOutgoingCallIntent(callees: aliases,
                                         options: CallOptions(callType: .audioVideo,
                                                              recorded: false,
                                                              duration: 0))

        // Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    // MARK: - Chat ViewController

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

        chatPresenter.presentChatView(chatViewControllerWrapper)
    }

    // MARK: - Call ViewController

    private func performCallViewControllerPresentation() {
        guard let intent = self.intent else { return }

        prepareForCallViewControllerPresentation()

        // Here we tell the call window to present the Call UI if there is not another call in progress.
        // Otherwise you should handle the error notified as the closure argument.

        callWindow?.presentCallViewController(for: intent) { [weak self] error in
            guard let error = error else { return }
            guard let self = self else { return }

            switch error {
            case let presentationError as CallPresentationError where presentationError.errorCode == CallPresentationErrorCode.anotherCallOnGoing.rawValue:
                self.presentAlert(title: "Warning", message: "Another call ongoing.")
            default:
                self.presentAlert(title: "Error", message: "Impossible to start a call now. Try again later.")
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        alertPresenter.presentAlert(title: title, message: message)
    }

    private func prepareForCallViewControllerPresentation() {
        initCallWindowIfNeeded()

        // Here we are configuring the CallViewController instance.
        // A `CallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
        let config = CallViewControllerConfiguration()

        let filePath = Bundle.main.path(forResource: "SampleVideo_640x360_10mb", ofType: "mp4")

        guard let path = filePath else {
            fatalError("The fake file for the file capturer could not be found")
        }

        // This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
        let url = URL(fileURLWithPath: path)
        config.fakeCapturerFileURL = url

        // Here, we set the configuration object created. You must set the view controller configuration object before the view controller
        // view is loaded, otherwise an exception is thrown.
        callWindow?.setConfiguration(config)
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

    // MARK: - Presenters

    class AlertPresenter: ObservableObject {

        @Published var showingAlert: Bool = false
        var alertTitle = ""
        var alertMessage = ""

        fileprivate func presentAlert(title: String, message: String) {
            alertTitle = title
            alertMessage = message
            showingAlert = true
        }
    }

    class ChatPresenter: ObservableObject {
        @Published var showingChat: Bool = false
        var chatViewToPresent = ChatViewControllerWrapper()

        fileprivate func presentChatView(_ view: ChatViewControllerWrapper) {
            chatViewToPresent = view
            showingChat = true
        }
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
        chatPresenter.showingChat = false
    }

    func channelViewController(_ controller: ChannelViewController, didTapAudioCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioUpgradable)
    }

    func channelViewController(_ controller: ChannelViewController, didTapVideoCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioVideo)
    }

    private func dismiss(channelViewController: ChannelViewController, presentCallViewControllerWith callees: [String], type: Bandyer.CallType) {
        chatPresenter.showingChat = false

        intent = StartOutgoingCallIntent(callees: callees, options: CallOptions(callType: type))
        performCallViewControllerPresentation()
    }
}

// MARK: - In App file share notification touch listener delegate

extension ContactsViewModel: InAppChatNotificationTouchListener {
    
    func onTouch(_ notification: ChatNotification) {
        chatPresenter.showingChat = false
        presentChat(from: notification)
    }
}

// MARK: - In App file share notification touch listener delegate

extension ContactsViewModel: InAppFileShareNotificationTouchListener {

    func onTouch(_ notification: FileShareNotification) {
        callWindow?.presentCallViewController(for: OpenDownloadsIntent())
    }
}

struct ChatViewControllerWrapper: UIViewControllerRepresentable {

    private var channelViewController = ChannelViewController()

    var delegate: ChannelViewControllerDelegate? {
        get {
            channelViewController.delegate
        }
        set {
            channelViewController.delegate = newValue
        }
    }

    var intent: OpenChatIntent? {
        get {
            channelViewController.intent
        }
        set {
            channelViewController.intent = newValue
        }
    }

    func makeUIViewController(context: Context) -> ChannelViewController {
        channelViewController
    }

    func updateUIViewController(_ uiViewController: ChannelViewController, context: Context) { }
}
