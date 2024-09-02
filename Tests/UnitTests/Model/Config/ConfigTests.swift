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
        let sut = Config(keys: .any, showUserInfo: true, environment: .production, cameraPosition: .back)

        assertThat(sut.keys, equalTo(.any))
        assertThat(sut.region, equalTo(.europe))
        assertThat(sut.showUserInfo, isTrue())
        assertThat(sut.voip, equalTo(.default))
        assertThat(sut.environment, equalTo(.production))
        assertThat(sut.cameraPosition, equalTo(.back))
    }

    // MARK: - Base URL

    func testBaseURL() {
        assertBaseURL(environment: .production, region: .europe, equalTo: "https://cs.eu.bandyer.com")
        assertBaseURL(environment: .sandbox, region: .europe, equalTo: "https://cs.sandbox.eu.bandyer.com")
        assertBaseURL(environment: .development, region: .europe, equalTo: "https://cs.development.eu.bandyer.com")

        assertBaseURL(environment: .production, region: .india, equalTo: "https://cs.in.bandyer.com")
        assertBaseURL(environment: .sandbox, region: .india, equalTo: "https://cs.sandbox.in.bandyer.com")
        assertBaseURL(environment: .development, region: .india, equalTo: "https://cs.development.in.bandyer.com")

        assertBaseURL(environment: .production, region: .us, equalTo: "https://cs.us.bandyer.com")
        assertBaseURL(environment: .sandbox, region: .us, equalTo: "https://cs.sandbox.us.bandyer.com")
        assertBaseURL(environment: .development, region: .us, equalTo: "https://cs.development.us.bandyer.com")
    }

    // MARK: - Environment

    func testEnvironmentsForRegion() {
        assertThat(Config.Environment.environmentsFor(region: .europe), equalTo([.production, .sandbox, .development]))
        assertThat(Config.Environment.environmentsFor(region: .india), equalTo([.production]))
        assertThat(Config.Environment.environmentsFor(region: .us), equalTo([.production]))
    }

    // MARK: - Decodable

    func testDecodesInstanceFromDataContainingAllOptions() throws {
        var tools = Config.Tools()
        tools.isChatEnabled = true
        tools.isScreenshareEnabled = true
        tools.isFileshareEnabled = true
        tools.isWhiteboardEnabled = true
        tools.isBroadcastEnabled = true

        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "region" : "india",
            "showUserInfo" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            },
            "disableDirectIncomingCalls" : true,
            "voip": {
                "manual": {
                    "strategy" : {
                        "backgroundOnly" : {}
                    }
                }
            },
            "cameraPosition" : "back"
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.keys, equalTo(.any))
        assertThat(decoded.environment, equalTo(.sandbox))
        assertThat(decoded.region, equalTo(.india))
        assertThat(decoded.showUserInfo, isTrue())
        assertThat(decoded.disableDirectIncomingCalls, isTrue())
        assertThat(decoded.voip, equalTo(.manual(strategy: .backgroundOnly)))
        assertThat(decoded.tools, equalTo(tools))
        assertThat(decoded.cameraPosition, equalTo(.back))
    }

    func testDecodesConfigUsingDefaultVoIPConfigurationWhenVoIPConfigIsMissing() throws {
        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "showUserInfo" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            }
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
            "manuallyHandleVoIPNotifications" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            }
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
            "manuallyHandleVoIPNotifications" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            }
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.region, equalTo(.india))
    }

    func testDecodeInstanceFromDataMissingCameraPositionShouldDefaultItToFront() throws {
        let json = """
        {
            "keys" : {
                "appId" : "mAppId_32d6da9f24c1b7s01bd2c61a",
                "apiKey" : "ak_live_18ad4c1f9dae593b114b6e3f"
            },
            "environment" : "sandbox",
            "region" : "india",
            "showUserInfo" : true,
            "manuallyHandleVoIPNotifications" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            }
        }
        """

        let decoded = try decode(json)

        assertThat(decoded.cameraPosition, equalTo(.front))
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
            "manuallyHandleVoIPNotifications" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            }
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
            "manuallyHandleVoIPNotifications" : true,
            "tools" : {
                "isChatEnabled" : true,
                "isScreenshareEnabled" : true,
                "isFileshareEnabled" : true,
                "isWhiteboardEnabled" : true,
                "isBroadcastEnabled" : true
            }
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
                         voip: Config.VoIP = .automatic(strategy: .backgroundOnly),
                         tools: Config.Tools = .default,
                         cameraPosition: Config.CameraPosition = .front) -> Config {
        .init(keys: keys,
              showUserInfo: showsUserInfo,
              environment: environment,
              region: region,
              disableDirectIncomingCalls: disableDirectIncomingCalls,
              voip: voip,
              tools: tools,
              cameraPosition: cameraPosition)
    }

    private func decode(_ json: String) throws -> Config {
        try JSONDecoder().decode(Config.self, from: Data(json.utf8))
    }

    // MARK: - Assertions

    private func assertBaseURL(environment: Config.Environment,
                               region: Config.Region,
                               equalTo expectedURL: String,
                               file: StaticString = #filePath,
                               line: UInt = #line) {
        assertThat(makeSUT(environment: environment, region: region).baseURL, equalTo(URL(string: expectedURL)), file: file, line: line)
    }
}
