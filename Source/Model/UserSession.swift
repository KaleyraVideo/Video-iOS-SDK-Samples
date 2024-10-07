// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

final class UserSession {

    let config: Config
    let user: Contact
    let addressBook: AddressBook
    let pushManager: PushManager

    init(config: Config, user: Contact, addressBook: AddressBook, services: ServicesFactory) {
        self.config = config
        self.user = user
        self.addressBook = addressBook
        self.pushManager = services.makePushManager(config: config)
    }

    func start() {
        pushManager.start(userId: user.alias)
    }

    func updatePushToken(_ token: String) {
        pushManager.pushTokenUpdated(token: token)
    }

    func stop() {
        pushManager.stop()
    }
}
