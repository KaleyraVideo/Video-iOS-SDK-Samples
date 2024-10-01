// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import PushKit
import Combine
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class VoIPNotificationsManager: NSObject, PKPushRegistryDelegate {

    private let config: Config
    private let registry: PushTokenRepository
    private let sdk: KaleyraVideo
    private var userId: String?
    private lazy var cancellables: Set<AnyCancellable> = .init()

    private var onPush: ((PKPushPayload) -> Void)?

    private var isStarted: Bool {
        userId != nil
    }

    private(set) var token: String?
    private var detector: VoIPNotificationsDetector?

    init(config: Config, registry: PushTokenRepository, sdk: KaleyraVideo) {
        self.config = config
        self.registry = registry
        self.sdk = sdk
    }

    func start(userId: String, onPush: @escaping (PKPushPayload) -> Void) {
        guard !isStarted else { return }

        self.userId = userId
        self.onPush = onPush

        switch config.voip {
            case .disabled:
                return
            case .manual:
                detector = .init(registryDelegate: self, config: config.voip)
                detector?.start()
            case .automatic:
                sdk.conference?.voipCredentialsPublisher.sink(receiveValue: { [weak self] credentials in
                    guard let credentials else { return }
                    if credentials.isValid {
                        self?.registerToken(token: credentials.tokenAsString, userId: userId)
                    } else {
                        self?.deregisterToken(token: credentials.tokenAsString, userId: userId)
                    }
                }).store(in: &cancellables)
        }
    }

    func stop() {
        guard let userId = self.userId else { return }

        if let token {
            deregisterToken(token: token, userId: userId)
        }

        self.detector?.stop()
        cancellables.removeAll()
        self.userId = nil
        self.onPush = nil
    }

    // MARK: - Token registration / deregistration

    private func registerToken(token: String, userId: String) {
        registry.registerToken(request: .init(userID: userId, token: token, isVoip: true), completion: { result in
            guard case Result.failure(let error) = result else { return }

            debugPrint("Could not register for VoIP notifications \(error)")
        })
    }

    private func deregisterToken(token: String, userId: String) {
        registry.deregisterToken(request: .init(userID: userId, token: token), completion: { result in
            guard case Result.failure(let error) = result else { return }

            debugPrint("Could not unsubscribe VoIP token \(error)")
        })
    }

    // MARK: - PKPushRegistryDelegate

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard !config.voip.isDisabled else { return }
        guard let userId = self.userId else { return }

        let token = pushCredentials.token.pushToken
        self.token = token
        self.registerToken(token: token, userId: userId)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        onPush?(payload)
        completion()
    }
}
