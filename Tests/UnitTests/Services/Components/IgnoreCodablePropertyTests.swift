// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class IgnoreCodablePropertyTests: UnitTestCase {

    func testInitWithAProvidedValueShouldSetThatValueInValueProperty() {
        let value = "test"
        let sut = IgnoreCodableProperty(wrappedValue: value)

        assertThat(sut.wrappedValue, presentAnd(equalTo("test")))
    }

    func testInitFromDecoderShouldSetValuePropertyToNil() throws {
        let decoder = DecoderMock()
        let sut = try IgnoreCodableProperty<String>(from: decoder)

        assertThat(sut.wrappedValue, nilValue())
    }

    func testEncodeToEncoderShouldDoNothing() throws {
        let encoder = EncoderMock()
        let sut = IgnoreCodableProperty(wrappedValue: "Test")

        try sut.encode(to: encoder)

        assertThat(encoder.invocations, hasCount(0))
    }
}

private class DecoderMock: Decoder {

    init() {
        codingPath = []
        userInfo = [:]
    }

    var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any]

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw NotImplementedError()
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw NotImplementedError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw NotImplementedError()
    }

    private struct NotImplementedError: Error { }
}

private class EncoderMock: Encoder {

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var invocations: [()] = []

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        invocations.append(())
        fatalError()
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        invocations.append(())
        fatalError()
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        invocations.append(())
        fatalError()
    }
}

