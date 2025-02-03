// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

protocol SettingsRepository {

    func store(loggedUser alias: String?)
    func store(pushToken token: String?)
    func store(_ settings: CallSettings) throws
    func store(_ buttons: [Button.Custom]) throws
    func store(_ config: Config) throws
    func loadSettings() throws -> CallSettings
    func loadCustomButtons() throws -> [Button.Custom]
    func loadConfig() throws -> Config
    func loadLoggedUser() -> String?
    func loadPushToken() -> String?
    func reset()
}
