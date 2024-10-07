// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

final class UserSession {

    let config: Config
    let user: Contact
    let addressBook: AddressBook
    private let pushManager: PushManager
    private let _voipManager: Any

    @available(iOS 15.0, *)
    private var voipManager: VoIPNotificationsManager {
        _voipManager as! VoIPNotificationsManager
    }

    init(config: Config, user: Contact, addressBook: AddressBook, services: ServicesFactory) {
        self.config = config
        self.user = user
        self.addressBook = addressBook
        self.pushManager = services.makePushManager(config: config)
        if #available(iOS 15.0, *) {
            self._voipManager = services.makeVoIPManager(config: config)
        } else {
            self._voipManager = Optional<String>.none as Any
        }
    }

    func start() {
        pushManager.start(userId: user.alias)
        guard #available(iOS 15.0, *) else { return }
        voipManager.start(userId: user.alias)
    }

    func updatePushToken(_ token: String) {
        pushManager.pushTokenUpdated(token: token)
    }

    func stop() {
        pushManager.stop()
        guard #available(iOS 15.0, *) else { return }
        voipManager.stop()
    }
}
