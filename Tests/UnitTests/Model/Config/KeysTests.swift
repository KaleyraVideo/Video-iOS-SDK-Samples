// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class KeysTests: UnitTestCase {

    func testCreatesApiKeyFromString() {
        assertThat(makeApiKey("ak_test_Flv5809aac4c05e5")?.description, equalTo("ak_test_Flv5809aac4c05e5"))
        assertThat(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f")?.description, equalTo("ak_live_18ad4c1f9dae593b114b6e3f"))
        assertThat(makeApiKey("   ak_live_18ad4c1f9dae593b114b6e3f   ")?.description, equalTo("ak_live_18ad4c1f9dae593b114b6e3f"))
        assertThat(makeApiKey("18ad4c1f9dae593b114b6e3f")?.description, nilValue())
        assertThat(makeApiKey("ak_test_001")?.description, nilValue())
        assertThat(makeApiKey("")?.description, nilValue())
        assertThat(makeApiKey("ak_live18ad4c1f9dae593b114b6e3f")?.description, nilValue())
        assertThat(makeApiKey("mAppId_32d6da9f24c1b7s01bd2c61a")?.description, nilValue())
        assertThat(makeApiKey("""
                                 ak_live_18ad4c1f9dae593b114b6e3f


                                 """)?.description, equalTo("ak_live_18ad4c1f9dae593b114b6e3f"))
    }

    func testCreateAppIdFromString() {
        assertThat(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a")?.description, equalTo("mAppId_32d6da9f24c1b7s01bd2c61a"))
        assertThat(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782")?.description, equalTo("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782"))
        assertThat(makeAppId("    mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782   ")?.description, equalTo("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782"))
        assertThat(makeAppId("""

                                mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782


                                """)?.description, equalTo("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782"))
        assertThat(makeAppId("32d6da9f24c1b7s01bd2c61a")?.description, nilValue())
        assertThat(makeAppId("mAppId_")?.description, nilValue())
        assertThat(makeAppId("")?.description, nilValue())
        assertThat(makeAppId("mAppId7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782")?.description, nilValue())
        assertThat(makeAppId("ak_test_Flv5809aac4c05e5")?.description, nilValue())
    }

    // MARK: - Equatable

    func testApiKeyEquality() {
        assertThat(makeApiKey("ak_test_Flv5809aac4c05e5"), equalTo(makeApiKey("ak_test_Flv5809aac4c05e5")))
        assertThat(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f"), equalTo(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f")))
        assertThat(makeApiKey("ak_test_Flv5809aac4c05e5"), not(equalTo(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f"))))
    }

    func testAppIdEquality() {
        assertThat(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a"), equalTo(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a")))
        assertThat(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782"), equalTo(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782")))
        assertThat(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a"), not(equalTo(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782"))))
    }

    // MARK: - Hashable

    func testApiKeyHash() {
        assertThat(makeApiKey("ak_test_Flv5809aac4c05e5").hashValue, equalTo(makeApiKey("ak_test_Flv5809aac4c05e5").hashValue))
        assertThat(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f").hashValue, equalTo(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f").hashValue))
        assertThat(makeApiKey("ak_test_Flv5809aac4c05e5").hashValue, not(equalTo(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f").hashValue)))
    }

    func testAppIdHash() {
        assertThat(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a").hashValue, equalTo(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a").hashValue))
        assertThat(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782").hashValue, equalTo(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782").hashValue))
        assertThat(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a").hashValue, not(equalTo(makeAppId("mAppId_7b6c265418d0984bdc3e9e9f32c559f1e3ee25a85ea7105b0223ddf5d782").hashValue)))
    }

    // MARK: - Decodable

    func testDecodesValidAppId() throws {
        let json = #""mAppId_32d6da9f24c1b7s01bd2c61a""#

        let decoded = try decode(Config.AppId.self, from: json)

        assertThat(decoded, equalTo(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a")))
    }

    func testThrowsErrorWhenDecodingInvalidAppId() throws {
        let json = #""foo""#

        assertThrows(try decode(Config.AppId.self, from: json), equalTo(InvalidAppIdError()))
    }

    func testDecodesValidApiKey() throws {
        let json = #""ak_live_18ad4c1f9dae593b114b6e3f""#

        let decoded = try decode(Config.ApiKey.self, from: json)

        assertThat(decoded, equalTo(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f")))
    }

    func testThrowsErrorWhenDecodingInvalidApiKey() throws {
        let json = #""foo""#

        assertThrows(try decode(Config.ApiKey.self, from: json), equalTo(InvalidApiKeyError()))
    }

    // MARK: - Encodable

    func testEncodeAppId() throws {
        let expected = #""mAppId_32d6da9f24c1b7s01bd2c61a""#

        assertThat(try encode(makeAppId("mAppId_32d6da9f24c1b7s01bd2c61a")), equalTo(expected))
    }

    func testEncodeApiKey() throws {
        let expected = #""ak_live_18ad4c1f9dae593b114b6e3f""#

        assertThat(try encode(makeApiKey("ak_live_18ad4c1f9dae593b114b6e3f")), equalTo(expected))
    }

    // MARK: - Helpers

    private func makeApiKey(_ rawValue: String) -> Config.ApiKey? {
        try? .init(rawValue)
    }

    private func makeAppId(_ rawValue: String) -> Config.AppId? {
        try? .init(rawValue)
    }

    private func decode<D: Decodable>(_ type: D.Type, from json: String) throws -> D {
        try JSONDecoder().decode(D.self, from: json.data(using: .utf8)!)
    }

    private func encode<E: Encodable>(_ value: E) throws -> String {
        .init(data: try JSONEncoder().encode(value), encoding: .utf8)!
    }
}
