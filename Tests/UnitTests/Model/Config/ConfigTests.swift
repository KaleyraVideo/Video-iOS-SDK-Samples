// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class ConfigTests: UnitTestCase {

    func testDesignatedInitializerShouldDefaultToSandboxEnvironment() {
        let sut = Config(keys: .any, showUserInfo: true)

        assertThat(sut.keys, equalTo(.any))
        assertThat(sut.showUserInfo, isTrue())
        assertThat(sut.voip, equalTo(.default))
        assertThat(sut.environment, equalTo(.sandbox))
    }

    func testDesignatedInitializer() {
        let sut = Config(keys: .any, showUserInfo: true, environment: .production)

        assertThat(sut.keys, equalTo(.any))
        assertThat(sut.region, equalTo(.europe))
        assertThat(sut.showUserInfo, isTrue())
        assertThat(sut.voip, equalTo(.default))
        assertThat(sut.environment, equalTo(.production))
    }

    // MARK: - Base URL

    func testBaseURL() {
        zip(Config.Environment.allCases, Config.Region.allCases).forEach { tuple in
            switch tuple {
                case (.production, .europe):
                    assertBaseURL(tuple, equalTo: "https://cs.eu.bandyer.com")
                case (.sandbox, .europe): 
                    assertBaseURL(tuple, equalTo: "https://cs.sandbox.eu.bandyer.com")
                case (.development, .europe):
                    assertBaseURL(tuple, equalTo: "https://cs.development.eu.bandyer.com")
                case (.production, .india):
                    assertBaseURL(tuple, equalTo: "https://cs.in.bandyer.com")
                case (.sandbox, .india):
                    assertBaseURL(tuple, equalTo: "https://cs.sandbox.in.bandyer.com")
                case (.development, .india):
                    assertBaseURL(tuple, equalTo: "https://cs.development.in.bandyer.com")
                case (.production, .us):
                    assertBaseURL(tuple, equalTo: "https://cs.us.bandyer.com")
                case (.sandbox, .us):
                    assertBaseURL(tuple, equalTo: "https://cs.sandbox.us.bandyer.com")
                case (.development, .us):
                    assertBaseURL(tuple, equalTo: "https://cs.development.us.bandyer.com")
                case (.production, .middleEast):
                    assertBaseURL(tuple, equalTo: "https://cs.me.bandyer.com")
                case (.sandbox, .middleEast):
                    assertBaseURL(tuple, equalTo: "https://cs.sandbox.me.bandyer.com")
                case (.development, .middleEast):
                    assertBaseURL(tuple, equalTo: "https://cs.development.me.bandyer.com")
            }
        }


    }

    // MARK: - Decodable

    func testDecodesConfigUsingDefaultVoIPConfigurationWhenVoIPConfigIsMissing() throws {
        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "showUserInfo" : true
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.voip, equalTo(.default))
    }

    func testDecodeShouldReturnDefaultRegionWhenRegionIsMissing() throws {
        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "showUserInfo" : true,
            "manuallyHandleVoIPNotifications" : true
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.region, equalTo(.europe))
    }

    func testDecodeShouldReturnEncodedRegion() throws {
        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "region" : "india",
            "showUserInfo" : true,
            "manuallyHandleVoIPNotifications" : true
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.region, equalTo(.india))
    }

    func testThrowsAnErrorWhenDecodingAnInvalidAppId() throws {
        let json = """
        {
            "keys" : {
                "appId" : "Appid",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "region" : "india",
            "showUserInfo" : true,
            "manuallyHandleVoIPNotifications" : true
        }
        """

        assertThrows(try decode(json))
    }

    func testThrowsAnErrorWhenDecodingAnInvalidApiKey() throws {
        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ApiKey"
            },
            "environment" : "sandbox",
            "region" : "india",
            "showUserInfo" : true,
            "manuallyHandleVoIPNotifications" : true
        }
        """

        assertThrows(try decode(json))
    }

    // MARK: - Helpers

    private func makeSUT(keys: Config.Keys = .any,
                         showsUserInfo: Bool = true,
                         environment: Config.Environment = .sandbox,
                         region: Config.Region = .europe,
                         disableDirectIncomingCalls: Bool = false,
                         voip: Config.VoIP = .automatic(strategy: .backgroundOnly)) -> Config {
        .init(keys: keys,
              showUserInfo: showsUserInfo,
              environment: environment,
              region: region,
              disableDirectIncomingCalls: disableDirectIncomingCalls,
              voip: voip)
    }

    private func decode(_ json: String) throws -> Config {
        try JSONDecoder().decode(Config.self, from: Data(json.utf8))
    }

    // MARK: - Assertions

    private func assertBaseURL(_ tuple: (environment: Config.Environment, region: Config.Region),
                               equalTo expectedURL: String,
                               file: StaticString = #filePath,
                               line: UInt = #line) {
        assertThat(makeSUT(environment: tuple.environment, region: tuple.region).baseURL, equalTo(URL(string: expectedURL)), file: file, line: line)
    }
}
