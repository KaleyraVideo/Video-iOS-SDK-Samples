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

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: - Tests

    func testStoresLoggedUserAlias() throws {
        let sut = try makeSUT()

        sut.setLoggedUser(userAlias: "test")

        assertThat(sut.getLoggedUserAlias(), presentAnd(equalTo("test")))
    }

    func testRemovesLoggedUserFromStoreWhenSettingNilLoggedUser() throws {
        let sut = try makeSUT()

        sut.setLoggedUser(userAlias: "test")
        sut.setLoggedUser(userAlias: nil)

        assertThat(sut.getLoggedUserAlias(), nilValue())
    }

    func testStoresDeviceToken() throws {
        let sut = try makeSUT()

        sut.setDeviceToken(token: "token")
        assertThat(sut.getDeviceToken(), presentAnd(equalTo("token")))

        sut.setDeviceToken(token: nil)
        assertThat(sut.getDeviceToken(), nilValue())
    }

    func testStoresCallOptionItem() throws {
        let sut = try makeSUT()
        var callOptions = CallOptions()
        callOptions.isGroup = true
        callOptions.maximumDuration = 40
        callOptions.recording = .automatic
        callOptions.type = .audioUpgradable

        sut.storeCallOptions(callOptions)

        let actual = sut.getCallOptions()
        assertThat(actual.type, equalTo(callOptions.type))
        assertThat(actual.recording, equalTo(callOptions.recording))
        assertThat(actual.maximumDuration, equalTo(callOptions.maximumDuration))
        assertThat(actual.isGroup, equalTo(callOptions.isGroup))
        assertThat(actual.showsRating, equalTo(callOptions.showsRating))
    }

    func testStoresConfig() throws {
        let sut = try makeSUT()
        let config = Config(keys: .any, showUserInfo: true, environment: .production, voip: .manual(strategy: .always))

        try sut.storeConfig(config)

        let actual = try unwrap(sut.getConfig())
        assertThat(actual, present())
        assertThat(actual.keys, equalTo(.any))
        assertThat(actual.showUserInfo, isTrue())
        assertThat(actual.voip, equalTo(.manual(strategy: .always)))
        assertThat(actual.environment, equalTo(.production))
    }

    // MARK: - Helpers

    private func makeSUT() throws -> UserDefaultsStore {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UserDefaultError.cannotLoadSuite
        }

        return UserDefaultsStore(userDefaults: userDefaults)
    }
}
