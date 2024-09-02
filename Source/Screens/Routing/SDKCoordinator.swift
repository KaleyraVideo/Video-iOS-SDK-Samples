// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import CallKit
import Intents
import Combine
import KaleyraVideoSDK

protocol SDKCoordinatorDelegate: AnyObject {
    func sdkDidFinish(withError: Error)
    func sdkIsLoading(_ isLoading: Bool)
}

final class SDKCoordinator: BaseCoordinator {

    enum Authentication {
        case accessToken(userId: String)
        case accessLink
    }

    private let currentViewController: UIViewController
    private let config: Config
    private let sdk: KaleyraVideo
    private let voipManager: VoIPNotificationsManager
    private let pushManager: PushManager
    private let tokenProvider: AccessTokenProvider
    private lazy var callWindow: CallWindow = {
        let window = CallWindow(windowScene: currentViewController.view.window!.windowScene!)
        window.tintColor = Theme.Color.primary
        return window
    }()

    var callOptions: CallOptions

    var isStarted: Bool { authentication != nil }

    private var isSdkConfigured: Bool = false

    private var authentication: Authentication?

    private var pendingIntent: ChannelViewController.Intent? {
        didSet {
            handleChatIntentIfPossible()
        }
    }

    weak var delegate: SDKCoordinatorDelegate?

    private lazy var cancellables = Set<AnyCancellable>()

    init(currentController: UIViewController,
         config: Config,
         services: ServicesFactory,
         delegate: SDKCoordinatorDelegate? = nil) {
        self.currentViewController = currentController
        self.config = config
        self.callOptions = services.makeUserDefaultsStore().getCallOptions()
        self.sdk = services.makeSDK()
        self.tokenProvider = services.makeTokenLoader(config: config)
        self.voipManager = services.makeVoIPManager(config: config)
        self.pushManager = services.makePushManager(config: config)
        self.delegate = delegate

        super.init(services: services)

        sdk.configure(config.sdk) { [weak self] result in
            try! result.get()
            self?.sdkConfigured()
        }
    }

    func start(authentication: Authentication) {
        self.authentication = authentication
        guard isSdkConfigured else { return }

        onReady(authentication: authentication)
    }

    private func sdkConfigured() {
        isSdkConfigured = true
        guard let authentication else { return }

        onReady(authentication: authentication)
    }

    private func onReady(authentication: Authentication) {
        if config.showUserInfo {
            sdk.userDetailsProvider = services.makeContactsStore(config: config).userDetailsProvider
        }

        sdk.conversation?.notificationsCoordinator.chatListener = self
        sdk.conversation?.notificationsCoordinator.start()

        if case Authentication.accessToken(userId: let userId) = authentication {
            sdk.conference?.statePublisher.receive(on: RunLoop.main).sink { [weak self] state in
                self?.callClientDidChangeState(newState: state)
            }.store(in: &cancellables)
            sdk.conversation?.statePublisher.receive(on: RunLoop.main).sink { [weak self] state in
                self?.chatClientDidChangeState(newState: state)
            }.store(in: &cancellables)
            sdk.conference?.registry.callAddedPublisher.receive(on: RunLoop.main).sink { [weak self] call in
                self?.present(call: call)
            }.store(in: &cancellables)
            sdk.connect(userId: userId, provider: tokenProvider) { _ in }

            voipManager.start(userId: userId) { [weak self] pushPayload in
                self?.sdk.conference?.handleNotification(pushPayload)
            }
            pushManager.start(userId: userId)
        }

        guard let call = sdk.conference?.registry.calls.first else { return }
        present(call: call)
    }

    func stop() {
        authentication = nil

        sdk.conversation?.notificationsCoordinator.stop()
        sdk.disconnect()
        sdk.userDetailsProvider = nil
        voipManager.stop()
        pushManager.stop()
        cancellables.removeAll()
    }

    func reset() {
        stop()
        sdk.reset()
    }

    // MARK: - Calls

    private func startOutgoingCall(userAliases: [String], type: KaleyraVideoSDK.CallOptions.CallType) {
        sdk.conference?.call(callees: userAliases, options: .init(type: type,
                                                                  recording: callOptions.recording,
                                                                  duration: callOptions.maximumDuration)) { result in
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
        let controller = CallViewController(call: call, configuration: callOptions.controllerConfig)
        controller.delegate = self
        callWindow.makeKeyAndVisible()
        callWindow.set(rootViewController: controller, animated: true)
    }

    // MARK: - Open chat

    private func openChat(channelID: String) {
        pendingIntent = .channel(id: channelID)
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

    // MARK: - Coordinator

    override func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool {
        switch event {
            case .shakeMotion, .shareLogFiles:
                return false
            case .pushToken(token: let token):
                pushManager.pushTokenUpdated(token: token)
            case .chatNotification(channelId: let channelId):
                openChat(channelID: channelId)
            case .startCall(let url):
                startJoinCall(url: url)
            case .startOutgoingCall(type: let type, callees: let callees):
                startOutgoingCall(userAliases: callees, type: type ?? callOptions.type)
            case .openChat(userId: let userId):
                openChat(userId: userId)
            case .siri(intent: let intent):
                handleSiriIntent(intent)
        }
        return true
    }
}

extension SDKCoordinator {

    func chatClientDidChangeState(newState: ClientState) {
        switch newState {
            case .connecting, .reconnecting:
                delegate?.sdkIsLoading(true)
            case .connected:
                delegate?.sdkIsLoading(false)
                handleChatIntentIfPossible()
            case .disconnected(error: let error):
                delegate?.sdkIsLoading(false)

                guard let error else { return }

                delegate?.sdkDidFinish(withError: error)
        }
    }
}

// MARK: - Call client observer

extension SDKCoordinator {

    func callClientDidChangeState(newState: ClientState) {
        switch newState {
            case .connecting, .reconnecting:
                delegate?.sdkIsLoading(true)
            case .connected:
                delegate?.sdkIsLoading(false)
            case .disconnected:
                delegate?.sdkIsLoading(false)
        }
    }

    private func handleSiriIntent(_ intent: INIntent) {
        guard let startCallIntent = intent as? INStartCallIntent else { return }
        
    }
}

// MARK: - Present Chat ViewController

extension SDKCoordinator {

    private func presentChat(intent: ChannelViewController.Intent) {
        if let presentedController = currentViewController.presentedViewController as? ChannelViewController {
            presentedController.dismiss(animated: true) { [weak self] in
                self?.createAndPresentChatController(intent: intent)
            }
        } else {
            createAndPresentChatController(intent: intent)
        }
    }

    private func createAndPresentChatController(intent: ChannelViewController.Intent) {
        let controller = ChannelViewController(intent: intent, configuration: .init(audioButton: true, videoButton: true))
        controller.delegate = self
        currentViewController.present(controller, animated: true)
    }
}

// MARK: - In App chat notification touch listener delegate

extension SDKCoordinator: InAppChatNotificationTouchListener {

    func onTouch(_ notification: ChatNotification) {
        presentChat(intent: .notification(notification))
    }
}

// MARK: - Call window delegate

extension SDKCoordinator: CallViewControllerDelegate {

    func callViewControllerDidFinish(_ controller: CallViewController) {
        callWindow.set(rootViewController: nil, animated: true) { _ in
            self.callWindow.isHidden = true
        }
    }
}

// MARK: - Channel view controller delegate

extension SDKCoordinator: ChannelViewControllerDelegate {

    func channelViewControllerDidFinish(_ controller: ChannelViewController) {
        controller.dismiss(animated: true)
    }

    func channelViewController(_ controller: ChannelViewController, didTapAudioCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioUpgradable)
    }

    func channelViewController(_ controller: ChannelViewController, didTapVideoCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioVideo)
    }

    private func dismiss(channelViewController: ChannelViewController, presentCallViewControllerWith callees: [String], type: KaleyraVideoSDK.CallOptions.CallType) {
        guard let _ = currentViewController.presentedViewController as? ChannelViewController else {
            startOutgoingCall(userAliases: callees, type: type)
            return
        }

        channelViewController.dismiss(animated: true) { [weak self] in
            self?.startOutgoingCall(userAliases: callees, type: type)
        }
    }
}

extension CallOptions {

    var controllerConfig: CallViewController.Configuration {
        var config = CallViewController.Configuration()
        config.feedback = showsRating ? .init() : nil
        config.presentationMode = presentationMode == .pip ? .pip : .fullscreen
        return config
    }
}
