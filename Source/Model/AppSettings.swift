// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import Combine

final class AppSettings {

    @Published
    var callSettings: CallSettings = .init()

    @Published
    var customButtons: [Button.Custom] = []

    func loadFromDefaults(_ repository: SettingsRepository) {
        customButtons = (try? repository.loadCustomButtons()) ?? []
        callSettings = (try? repository.loadSettings()) ?? .init()
    }
}
