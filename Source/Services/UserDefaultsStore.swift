// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

final class UserDefaultsStore {

    private enum Key: String {
        case loggedUser = "com.acme.logged_user_id"
        case pushDeviceToken = "com.acme.device_token"
        case config = "com.acme.environment_options"
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Functions

    func getLoggedUserAlias() -> String? {
        guard let userAlias = userDefaults.object(forKey: Key.loggedUser.rawValue) as? String else {
            return nil
        }
        return userAlias
    }

    func setLoggedUser(userAlias: String?) {
        userDefaults.set(userAlias, forKey: Key.loggedUser.rawValue)
        userDefaults.synchronize()
    }

    func setDeviceToken(token: String?) {
        userDefaults.set(token, forKey: Key.pushDeviceToken.rawValue)
        userDefaults.synchronize()
    }

    func getDeviceToken() -> String? {
        guard let token = userDefaults.object(forKey: Key.pushDeviceToken.rawValue) as? String else {
            return nil
        }

        return token
    }

    func storeCallOptions(_ options: CallOptions) {
        options.store(in: userDefaults)
        userDefaults.synchronize()
    }

    func getCallOptions() -> CallOptions {
        guard let options = CallOptions(from: userDefaults) else {
            return .init()
        }

        return options
    }

    func storeConfig(_ config: Config) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        userDefaults.set(data, forKey: Key.config.rawValue)
    }

    func getConfig() -> Config? {
        guard let data = userDefaults.data(forKey: Key.config.rawValue) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(Config.self, from: data)
        } catch {
            return nil
        }
    }

    func resetConfigAndUser() {
        userDefaults.removeObject(forKey: Key.config.rawValue)
        userDefaults.removeObject(forKey: Key.loggedUser.rawValue)
        userDefaults.synchronize()
    }

}

