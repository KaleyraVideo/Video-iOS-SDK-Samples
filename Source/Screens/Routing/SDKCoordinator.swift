// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import CallKit
import Intents
import Combine
import KaleyraVideoSDK

final class SDKCoordinator: BaseCoordinator {

    enum Authentication {
        case accessToken(userId: String)
        case accessLink
    }

    private let controller: UIViewController
    private let config: Config
    private let sdk: KaleyraVideo
    private let appSettings: AppSettings
    private let voipManager: VoIPNotificationsManager
    private let pushManager: PushManager
    private let tokenProvider: AccessTokenProvider
    private lazy var callWindow: CallWindow = {
        let window = CallWindow(windowScene: controller.view.window!.windowScene!)
        window.tintColor = Theme.Color.primary
        return window
    }()

    private var pendingIntent: ChannelViewController.Intent? {
        didSet {
            handleChatIntentIfPossible()
        }
    }

    private lazy var subscriptions = Set<AnyCancellable>()

    init(controller: UIViewController,
         config: Config,
         appSettings: AppSettings,
         services: ServicesFactory) {
        self.controller = controller
        self.config = config
        self.appSettings = appSettings
        self.sdk = services.makeSDK()
        self.tokenProvider = services.makeAccessTokenProvider(config: config)
        self.voipManager = services.makeVoIPManager(config: config)
        self.pushManager = services.makePushManager(config: config)

        super.init(services: services)

        try! sdk.configure(config.sdk)
    }

    func start(authentication: Authentication) {
        if config.showUserInfo {
            sdk.userDetailsProvider = services.makeContactsStore(config: config).userDetailsProvider
        }

        sdk.conversation?.notificationsCoordinator.chatListener = self
        sdk.conversation?.notificationsCoordinator.start()

        if case Authentication.accessToken(userId: let userId) = authentication {
            sdk.conversation?.statePublisher.filter(\.isConnected).receive(on: RunLoop.main).sink { [weak self] state in
                self?.handleChatIntentIfPossible()
            }.store(in: &subscriptions)
            sdk.conference?.registry.callAddedPublisher.receive(on: RunLoop.main).sink { [weak self] call in
                self?.present(call: call)
            }.store(in: &subscriptions)

            try? sdk.connect(userId: userId, provider: tokenProvider)

            voipManager.start(userId: userId) { [weak self] pushPayload in
                self?.sdk.conference?.handleNotification(pushPayload)
            }
            pushManager.start(userId: userId)
        }

        guard let call = sdk.conference?.registry.calls.first else { return }
        present(call: call)
    }

    func stop() {
        sdk.conversation?.notificationsCoordinator.stop()
        sdk.disconnect()
        sdk.userDetailsProvider = nil
        voipManager.stop()
        pushManager.stop()
        subscriptions.removeAll()
    }

    func reset() {
        stop()
        sdk.reset()
    }

    // MARK: - Calls

    private func startOutgoingCall(userAliases: [String], type: KaleyraVideoSDK.CallOptions.CallType) {
        sdk.conference?.call(callees: userAliases, options: .init(type: type,
                                                                  recording: appSettings.callSettings.recording,
                                                                  duration: appSettings.callSettings.maximumDuration)) { result in
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

    private func presentChat(intent: ChannelViewController.Intent) {
        if let presentedController = controller.presentedViewController as? ChannelViewController {
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
        self.controller.present(controller, animated: true)
    }

    // MARK: - Coordinator

    override func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool {
        switch event {
            case .shareLogFiles:
                return false
            case .pushToken(token: let token):
                pushManager.pushTokenUpdated(token: token)
            case .chatNotification(channelId: let channelId):
                openChat(channelID: channelId)
            case .startCall(let url):
                startJoinCall(url: url)
            case .startOutgoingCall(type: let type, callees: let callees):
                startOutgoingCall(userAliases: callees, type: type ?? appSettings.callSettings.type)
            case .openChat(userId: let userId):
                openChat(userId: userId)
            case .siri(intent: let intent):
                handleSiriIntent(intent)
        }
        return true
    }

    private func handleSiriIntent(_ intent: INIntent) {
        guard intent is INStartVideoCallIntent else { return }

        sdk.conference?.registry.calls.last?.upgradeToVideo(completion: { _ in })
    }
}

extension SDKCoordinator: InAppChatNotificationTouchListener {

    func onTouch(_ notification: ChatNotification) {
        presentChat(intent: .channel(id: notification.channelId))
    }
}

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
        guard let _ = controller.presentedViewController as? ChannelViewController else {
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
