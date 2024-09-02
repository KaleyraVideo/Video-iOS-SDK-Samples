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

        let config = try parse(url)

        assertThat(config.userAlias, equalTo(.bob))
        assertThat(config.keys.appId, equalTo(Config.Keys.validAppId))
        assertThat(config.keys.apiKey, equalTo(Config.Keys.validApiKey))
        assertThat(config.defaultCallType, equalTo(.audio_video))
        assertThat(config.environment, equalTo(.sandbox))
        assertThat(config.region, equalTo(.us))
    }

    func testParsesCallTypes() throws {
        assertThat(try parse(makeValidConfiguration(callType: "AUDIO_VIDEO")).defaultCallType, equalTo(.audio_video))
        assertThat(try parse(makeValidConfiguration(callType: "AUDIO_ONLY")).defaultCallType, equalTo(.audio_only))
        assertThat(try parse(makeValidConfiguration(callType: "AUDIO_UPGRADABLE")).defaultCallType, equalTo(.audio_upgradable))
        assertThat(try parse(makeValidConfiguration(callType: "UNKNOWN_CALL_TYPE")).defaultCallType, nilValue())
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

        let config = try parse(url).makeConfig()

        assertThat(config.keys, equalTo(.any))
        assertThat(config.environment, equalTo(.sandbox))
        assertThat(config.region, equalTo(.us))
        assertThat(config.voip, equalTo(.default))
        assertThat(config.disableDirectIncomingCalls, isFalse())
        assertThat(config.showUserInfo, isTrue())
        assertThat(config.tools, equalTo(.default))
        assertThat(config.cameraPosition, equalTo(.front))
    }

    // MARK: - Helpers

    private func parse(_ url: URL) throws -> QRCode {
        try QRCode.parse(from: url)
    }
}

