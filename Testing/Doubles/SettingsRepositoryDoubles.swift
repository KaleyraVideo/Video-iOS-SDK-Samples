// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

struct SettingsRepositoryDummy: SettingsRepository {

    func store(loggedUser alias: String?) {}

    func store(pushToken token: String?) {}

    func store(_ settings: SDK_Sample.CallSettings) throws {}

    func store(_ buttons: [SDK_Sample.Button.Custom]) throws {}

    func store(_ config: SDK_Sample.Config) throws {}

    func loadSettings() throws -> SDK_Sample.CallSettings {
        .init()
    }
    
    func loadCustomButtons() throws -> [SDK_Sample.Button.Custom] {
        []
    }

    func loadConfig() throws -> SDK_Sample.Config {
        .init(keys: .any)
    }

    func loadLoggedUser() -> String? { nil }

    func loadPushToken() -> String? { nil }

    func reset() {}

}
