// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class UserDefaultsStoreTests: UnitTestCase {

    private enum UserDefaultError: Error {
        case cannotLoadSuite
    }

    private let suiteName = "com.kaleyra.user-defaults-test"

    private var sut: UserDefaultsStore!

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UserDefaultError.cannotLoadSuite
        }

        sut = .init(userDefaults: userDefaults)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: - Tests

    func testStoresLoggedUserAlias() {
        sut.store(loggedUser: .alice)

        assertThat(sut.loadLoggedUser(), presentAnd(equalTo(.alice)))
    }

    func testRemovesLoggedUserFromStoreWhenSettingNilLoggedUser() {
        sut.store(loggedUser: .alice)

        sut.store(loggedUser: nil)

        assertThat(sut.loadLoggedUser(), nilValue())
    }

    func testStoresDeviceToken() {
        sut.store(pushToken: .foobar)
        assertThat(sut.loadPushToken(), presentAnd(equalTo(.foobar)))

        sut.store(pushToken: nil)
        assertThat(sut.loadPushToken(), nilValue())
    }

    func testStoresCallSettings() throws {
        var settings = CallSettings()
        settings.isGroup = true
        settings.maximumDuration = 40
        settings.recording = .automatic
        settings.type = .audioUpgradable

        try sut.store(settings)

        let actual = try sut.loadSettings()
        assertThat(actual, equalTo(settings))
    }

    func testStoresConfig() throws {
        let config = Config(keys: .any, showUserInfo: true, environment: .production, voip: .manual(strategy: .always))

        try sut.store(config)

        let actual = try unwrap(sut.loadConfig())
        assertThat(actual, present())
        assertThat(actual.keys, equalTo(.any))
        assertThat(actual.showUserInfo, isTrue())
        assertThat(actual.voip, equalTo(.manual(strategy: .always)))
        assertThat(actual.environment, equalTo(.production))
    }
}
