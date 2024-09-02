// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class SettingViewControllerUITests: SnapshotTestCase {

    func testDisplaysAppAndUserInfoInDetailsSection() {
        let user = Contact("Bob")
        let versions = Versions(app: .init(marketing: "1.1.1", build: nil), sdk: .init(marketing: "2.2.0", build: nil))
        let sut = makeSUT(user: user, environment: .sandbox, region: .europe, versions: versions)
        sut.loadViewIfNeeded()

        verifySnapshot(sut)
    }

    // MARK: - Helpers

    private func makeSUT(user: Contact, environment: Config.Environment, region: Config.Region, versions: SDK_Sample.Versions) -> SettingsViewController {
#if SAMPLE_CUSTOMIZABLE_THEME
        SettingsViewController(user: user, config: .init(keys: .any, environment: environment, region: region), versions: versions, themeStorage: DummyThemeStorage())
#else
        SettingsViewController(user: user, config: .init(keys: .any, environment: environment, region: region), settingsStore: UserDefaultsStore(), versions: versions)
#endif
    }
}
