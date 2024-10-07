// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

final class UserDefaultsStore: SettingsRepository {

    private enum Key: String {
        case loggedUser = "com.kaleyra.logged_user"
        case pushDeviceToken = "com.kaleyra.push_token"
        case callSettings = "com.kaleyra.call_settings"
        case config = "com.kaleyra.config"
    }

    private enum Errors: Error {
        case objectNotFoundInDefaults
    }

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }

    // MARK: - Functions

    func store(loggedUser alias: String?) {
        defaults.set(alias, forKey: Key.loggedUser)
        defaults.synchronize()
    }

    func store(pushToken token: String?) {
        defaults.set(token, forKey: Key.pushDeviceToken)
        defaults.synchronize()
    }

    func store(_ settings: CallSettings) throws {
        try store(settings, key: .callSettings)
        defaults.synchronize()
    }

    func store(_ config: Config) throws {
        try store(config, key: .config)
        defaults.synchronize()
    }

    func loadSettings() throws -> CallSettings {
        try load(key: .callSettings)
    }

    func loadConfig() throws -> Config {
        try load(key: .config)
    }

    func loadLoggedUser() -> String? {
        guard let userAlias = defaults.object(forKey: Key.loggedUser) as? String else {
            return nil
        }
        return userAlias
    }

    func loadPushToken() -> String? {
        guard let token = defaults.object(forKey: Key.pushDeviceToken) as? String else {
            return nil
        }

        return token
    }

    func reset() {
        defaults.removeObject(forKey: Key.config)
        defaults.removeObject(forKey: Key.loggedUser)
        defaults.synchronize()
    }

    private func load<T: Decodable>(_ type: T.Type = T.self, key: Key) throws -> T {
        guard let object = defaults.object(forKey: key) else {
            throw Errors.objectNotFoundInDefaults
        }
        let data = try JSONSerialization.data(withJSONObject: object, options: [.fragmentsAllowed])
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func store<T: Encodable>(_ value: T, key: Key) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        let object = try JSONSerialization.jsonObject(with: data)
        defaults.set(object, forKey: key)
    }
}

private extension UserDefaults {

    func set<Key: RawRepresentable>(_ object: Any?, forKey key: Key) where Key.RawValue == String {
        set(object, forKey: key.rawValue)
    }

    func object<Key: RawRepresentable>(forKey key: Key) -> Any? where Key.RawValue == String {
        object(forKey: key.rawValue)
    }

    func removeObject<Key: RawRepresentable>(forKey key: Key) where Key.RawValue == String {
        removeObject(forKey: key.rawValue)
    }
}
