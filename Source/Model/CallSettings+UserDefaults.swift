// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension CallSettings {

    private enum DefaultsKeys: String {
        case callSettings = "com.kaleyra.call_settings"
    }

    private enum Errors: Error {
        case objectNotFoundInDefaults
    }

    init(from defaults: UserDefaults) throws {
        guard let object = defaults.object(forKey: DefaultsKeys.callSettings.rawValue) else {
            throw Errors.objectNotFoundInDefaults
        }
        let data = try JSONSerialization.data(withJSONObject: object, options: [.fragmentsAllowed])
        let decoder = JSONDecoder()
        self = try decoder.decode(CallSettings.self, from: data)
    }

    func store(in defaults: UserDefaults) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        defaults.set(object, forKey: DefaultsKeys.callSettings.rawValue)
    }
}
