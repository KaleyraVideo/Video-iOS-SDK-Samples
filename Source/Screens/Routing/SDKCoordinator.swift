// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import CallKit
import Intents
import Combine
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class SDKCoordinator: BaseCoordinator {

    enum Authentication {
        case accessToken(userId: String)
        case accessLink
    }

    private let controller: UIViewController
    private let config: Config
    private let sdk: KaleyraVideo
    private let book: AddressBook
    private let appSettings: AppSettings
    private let tokenProvider: AccessTokenProvider
    private lazy var callWindow: CallWindow = {
        let window = CallWindow(windowScene: controller.view.window!.windowScene!)
        window.tintColor = Theme.Color.primary
        return window
    }()

    private var pendingIntent: ChatViewController.Intent? {
        didSet {
            handleChatIntentIfPossible()
        }
    }

    private lazy var subscriptions = Set<AnyCancellable>()
    private var floatingMessage: FloatingMessage?

    init(controller: UIViewController,
         config: Config,
         book: AddressBook,
         appSettings: AppSettings,
         services: ServicesFactory) {
        self.controller = controller
        self.config = config
        self.book = book
        self.appSettings = appSettings
        self.sdk = services.makeSDK()
        self.tokenProvider = services.makeAccessTokenProvider(config: config)

        super.init(services: services)

        try! sdk.configure(config.sdk)
    }

    func start(authentication: Authentication) {
        appSettings.$callSettings.sink { [weak self] in
            self?.sdk.conference?.settings.speakerOverride = $0.speakerOverride
            self?.sdk.conference?.settings.tools = $0.tools.asSDKSettings
            self?.sdk.conference?.settings.camera = $0.cameraPosition == .front ? .front : .back
        }.store(in: &subscriptions)

        if config.showUserInfo {
            sdk.userDetailsProvider = book.userDetailsProvider
        }

        sdk.conversation?.notifications.delegate = self
        sdk.conversation?.notifications.start()
        sdk.conference?.callPublisher.compactMap({ $0 }).receive(on: RunLoop.main).sink { [weak self] call in
            self?.present(call: call)
        }.store(in: &subscriptions)

        guard case Authentication.accessToken(userId: let userId) = authentication else { return }

        sdk.conversation?.statePublisher.filter(\.isConnected).receive(on: RunLoop.main).sink { [weak self] state in
            self?.handleChatIntentIfPossible()
        }.store(in: &subscriptions)
        try? sdk.connect(userId: userId, provider: tokenProvider)
    }

    func stop() {
        sdk.conversation?.notifications.stop()
        sdk.disconnect()
        sdk.userDetailsProvider = nil
        subscriptions.removeAll()
    }

    func reset() {
        stop()
        sdk.reset()
    }

    // MARK: - Calls

    private func startOutgoingCall(userAliases: [String], type: KaleyraVideoSDK.CallOptions.CallType, chatId: String?) {
        sdk.conference?.call(callees: userAliases,
                             options: .init(type: type,
                                            recording: appSettings.callSettings.recording,
                                            maxDuration: appSettings.callSettings.maximumDuration),
                             chatId: chatId) { result in
            do {
                try result.get()
            } catch {
                debugPrint("An error occurred while starting call \(error)")
            }
        }
    }

    private func startJoinCall(url: URL) {
        sdk.conference?.join(url: url) { result in
            do {
                try result.get()
            } catch {
                debugPrint("An error occurred while starting join call \(error)")
            }
        }
    }

    // MARK: - Present Call ViewController

    private func present(call: Call) {
        let controller = CallViewController(call: call, configuration: appSettings.callSettings.controllerConfig)
        controller.delegate = self
        controller.buttonsProvider = if appSettings.callSettings.enableCustomButtons {
            ButtonsProvider(buttons: appSettings.callSettings.buttons).provideButtons
        } else {
            nil
        }
        callWindow.makeKeyAndVisible()
        callWindow.set(rootViewController: controller, animated: true)
    }

    private func toggleFloatingMessage() {
        guard let controller = callWindow.rootViewController as? CallViewController else { return }

        if let floatingMessage {
            controller.dismiss(message: floatingMessage)
        } else {
            let message = FloatingMessage(body: "Hi, I'm a floating message. Shake to dismiss me",
                                          button: .init(text: "Tap me", icon: UIImage(systemName: "maps"), action: { [weak controller] in
                controller?.presentAlert(.floatingMessageAlert())
            }))
            controller.present(message: message)
            floatingMessage = message
        }
    }

    // MARK: - Open chat

    private func openChat(id: String) {
        pendingIntent = .chat(id: id)
    }

    private func openChat(userId: String) {
        pendingIntent = .participant(id: userId)
    }

    private func handleChatIntentIfPossible() {
        guard sdk.conversation?.state == .connected else { return }
        guard let pendingIntent else { return }

        presentChat(intent: pendingIntent)
        self.pendingIntent = nil
    }

    private func presentChat(intent: ChatViewController.Intent) {
        if let presentedController = controller.presentedViewController as? ChatViewController {
            presentedController.dismiss(animated: true) { [weak self] in
                self?.createAndPresentChatController(intent: intent)
            }
        } else {
            createAndPresentChatController(intent: intent)
        }
    }

    private func createAndPresentChatController(intent: ChatViewController.Intent) {
        let controller = ChatViewController(intent: intent, configuration: .init(audioButton: true, videoButton: true))
        controller.delegate = self
        self.controller.present(controller, animated: true)
    }

    // MARK: - Coordinator

    override func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool {
        switch event {
            case .shareLogFiles, .pushToken:
                return false
            case .chatNotification(chatId: let id):
                openChat(id: id)
            case .startCall(let url):
                startJoinCall(url: url)
            case .startOutgoingCall(type: let type, callees: let callees):
                startOutgoingCall(userAliases: callees, type: type ?? appSettings.callSettings.type, chatId: nil)
            case .openChat(userId: let userId):
                openChat(userId: userId)
            case .siri(intent: let intent):
                handleSiriIntent(intent)
            case .toggleFloatingMessage:
                toggleFloatingMessage()
        }
        return true
    }

    private func handleSiriIntent(_ intent: INIntent) {
        guard intent is INStartVideoCallIntent else { return }

        sdk.conference?.call?.upgradeToVideo(completion: { _ in })
    }
}

@available(iOS 15.0, *)
extension SDKCoordinator: InAppNotificationsDelegate {

    func onTouch(_ notification: ChatNotification) {
        presentChat(intent: .chat(id: notification.chatId))
    }
}

@available(iOS 15.0, *)
extension SDKCoordinator: CallViewControllerDelegate {

    func callViewControllerDidFinish(_ controller: CallViewController) {
        callWindow.set(rootViewController: nil, animated: true) { _ in
            self.callWindow.isHidden = true
        }
    }
}

// MARK: - Channel view controller delegate

@available(iOS 15.0, *)
extension SDKCoordinator: ChatViewControllerDelegate {

    func chatViewControllerDidFinish(_ controller: ChatViewController) {
        controller.dismiss(animated: true)
    }

    func chatViewControllerDidTapAudioCallButton(_ controller: ChatViewController) {
        dismiss(channelViewController: controller, thenStartCall: .audioUpgradable)
    }

    func chatViewControllerDidTapVideoCallButton(_ controller: ChatViewController) {
        dismiss(channelViewController: controller, thenStartCall: .audioVideo)
    }

    private func dismiss(channelViewController: ChatViewController, thenStartCall type: KaleyraVideoSDK.CallOptions.CallType) {
        guard let _ = controller.presentedViewController as? ChatViewController else {
            startOutgoingCall(userAliases: channelViewController.participants, type: type, chatId: channelViewController.chatId)
            return
        }

        channelViewController.dismiss(animated: true) { [weak self] in
            self?.startOutgoingCall(userAliases: channelViewController.participants, type: type, chatId: channelViewController.chatId)
        }
    }
}

@available(iOS 15.0, *)
extension CallSettings {

    var controllerConfig: CallViewController.Configuration {
        var config = CallViewController.Configuration()
        config.feedback = showsRating ? .init() : nil
        config.presentationMode = presentationMode == .pip ? .pip : .fullscreen
        return config
    }
}

@available(iOS 15.0, *)
private struct ButtonsProvider {

    let buttons: [Button]

    init(buttons: [Button]) {
        self.buttons = buttons
    }

    func provideButtons(_ buttons: [CallButton]) -> [CallButton] {
        self.buttons.compactMap(\.callButton)
    }
}

private extension UIAlertController {

    static func floatingMessageAlert() -> UIAlertController {
        let alert = UIAlertController.alert(title: "Warning!", message: "Shake to dismiss the toast")
        alert.addAction(.cancel(title: "Cancel"))
        return alert
    }
}
