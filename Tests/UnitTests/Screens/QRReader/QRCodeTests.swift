// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import AVFoundation
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class QRCodeTests: UnitTestCase, QRCodeFixtureFactory {

    func testParsesConfigurationFromURLQueryParameters() throws {
        let url = makeValidConfiguration(userId: .bob, environment: "sandbox", region: "us", appId: Config.Keys.validAppId.description, apiKey: Config.Keys.validApiKey.description, callType: "AUDIO_VIDEO")

        let qr = try parse(url)

        assertThat(qr.userAlias, equalTo(.bob))
        assertThat(qr.config.keys.appId, equalTo(Config.Keys.validAppId))
        assertThat(qr.config.keys.apiKey, equalTo(Config.Keys.validApiKey))
        assertThat(qr.config.environment, equalTo(.sandbox))
        assertThat(qr.config.region, equalTo(.us))
        assertThat(qr.callType, equalTo(.audioVideo))
    }

    func testParsesCallTypes() throws {
        assertThat(try parse(makeValidConfiguration(callType: "AUDIO_VIDEO")).callType, equalTo(.audioVideo))
        assertThat(try parse(makeValidConfiguration(callType: "AUDIO_ONLY")).callType, equalTo(.audioOnly))
        assertThat(try parse(makeValidConfiguration(callType: "AUDIO_UPGRADABLE")).callType, equalTo(.audioUpgradable))
        assertThat(try parse(makeValidConfiguration(callType: "UNKNOWN_CALL_TYPE")).callType, nilValue())
    }

    func testThrowsInvalidEnvironmentError() throws {
        assertThrows(try parse(makeValidConfiguration(environment: "unknown")), QRCode.ParseError.invalidEnvironment)
    }

    func testThrowsInvalidRegionError() throws {
        assertThrows(try parse(makeValidConfiguration(region: "unknown")), QRCode.ParseError.invalidRegion)
    }

    func testThrowsErrorWhenGivenInvalidConfigURL() throws {
        assertThrows(try parse(makeMalformedStringConfiguration()), QRCode.ParseError.missingRequiredConfigurationArguments)
    }

    func testMakeConfigShouldCreateConfigValue() throws {
        let url = makeValidConfiguration(userId: .bob, environment: "sandbox", region: "us", appId: Config.Keys.validAppId.description, apiKey: Config.Keys.validApiKey.description, callType: "AUDIO_VIDEO")

        let config = try parse(url).config

        assertThat(config.keys, equalTo(.any))
        assertThat(config.environment, equalTo(.sandbox))
        assertThat(config.region, equalTo(.us))
        assertThat(config.voip, equalTo(.default))
        assertThat(config.disableDirectIncomingCalls, isFalse())
        assertThat(config.showUserInfo, isTrue())
    }

    // MARK: - Helpers

    private func parse(_ url: URL) throws -> QRCode {
        try QRCode.parse(from: url)
    }
}

