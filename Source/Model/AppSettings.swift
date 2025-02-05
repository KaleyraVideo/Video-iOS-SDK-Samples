// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import Combine

final class AppSettings {

    private let repository: SettingsRepository

    @Published
    var callSettings: CallSettings = .init() {
        didSet {
            guard callSettings != oldValue else { return }

            try? repository.store(callSettings)
        }
    }

    @Published
    var customButtons: [Button.Custom] = [] {
        didSet {
            guard customButtons != oldValue else { return }

            try? repository.store(customButtons)
        }
    }

    init(repository: SettingsRepository) {
        self.repository = repository
        self.customButtons = (try? repository.loadCustomButtons()) ?? []
        self.callSettings = (try? repository.loadSettings()) ?? .init()
    }
}
