// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import Combine

final class AppSettings {

    @Published
    var callSettings: CallSettings = .init()

    func loadFromDefaults(_ userDefaults: UserDefaultsStore) {
        callSettings = (try? userDefaults.loadSettings()) ?? .init()
    }
}
