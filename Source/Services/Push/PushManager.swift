// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import UserNotifications

final class PushManager {

    private let registry: PushTokenRepository
    private let store: UserDefaultsStore
    private let center: UNUserNotificationCenter

    private var userId: String?
    private var token: String?

    private var isStarted: Bool { userId != nil }

    init(registry: PushTokenRepository, store: UserDefaultsStore, center: UNUserNotificationCenter = .current()) {
        self.registry = registry
        self.store = store
        self.center = center
    }

    func start(userId: String) {
        guard !isStarted else { return }

        self.userId = userId
        registerForPushNotifications()

        guard let token else { return }

        registerTokenOnRemote(token: token, userId: userId)
    }

    func pushTokenUpdated(token: String) {
        self.token = token
        store.store(pushToken: token)

        guard let userId else { return }

        registerTokenOnRemote(token: token, userId: userId)
    }

    func stop() {
        guard isStarted else { return }

        defer { userId = nil }

        guard let userId, let token else { return }

        deregisterTokenOnRemote(token: token, userId: userId)
    }

    // MARK: - Registration

    private func registerForPushNotifications() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                debugPrint("Push notifications disallowed by the user \(error)")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    private func registerTokenOnRemote(token: String, userId: String) {
        registry.registerToken(request: .init(userID: userId, token: token, isVoip: false)) { result in
            debugPrint("Push token registration result \(result)")
        }
    }

    private func deregisterTokenOnRemote(token: String, userId: String) {
        registry.deregisterToken(request: .init(userID: userId, token: token), completion: { result in
            debugPrint("Push token deregistration result \(result)")
        })
    }
}
