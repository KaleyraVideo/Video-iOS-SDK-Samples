// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class RestAccessTokenProviderTests: UnitTestCase, CompletionSpyFactory {

    private var client: HTTPClientMock!
    private var sut: RestAccessTokenProvider!
    private var completion: CompletionSpy<Result<RestAccessTokenProvider.AccessTokenResponse, Error>>!

    override func setUp() {
        super.setUp()

        client = .init()
        completion = makeCompletionSpy()
        sut = .init(client: client, config: .init(keys: .any, showUserInfo: true, environment: .sandbox))
    }

    override func tearDown() {
        sut = nil
        completion = nil
        client = nil

        super.tearDown()
    }

    func testLoadTokenCallCompletionWithErrorWhenClientReportsFailure() throws {
        sut.loadToken(options: .any, completion: completion.callAsFunction)

        try client.simulateFailure(error: anyNSError())

        assertThat(completion.invocations.first, presentAnd(isFailure()))
    }

    func testLoadTokenCallCompletionWithUserIdsWhenClientReportsSuccess() throws {
        sut.loadToken(options: .any, completion: completion.callAsFunction)
        try client.simulateSuccess(data: makeSuccessResponseRawData(accessToken: .foo, expiringDate: "2025-06-09T02:09:00.000Z"))

        let expectedDate = makeDate(year: 2025, month: 6, day: 9, hour: 2, minute: 9, second: 0)
        assertThat(completion.invocations.first, presentAnd(isSuccess(withValue: equalTo(.init(accessToken: .foo, expirationDate: expectedDate)))))
    }

    func testLoadTokenCallsCompletionWithErrorWhenClientReportsSuccessButDecodingFails() throws {
        sut.loadToken(options: .any, completion: completion.callAsFunction)

        try client.simulateSuccess(data: makeGarbageResponseData())

        assertThat(completion.invocations.first, presentAnd(isFailure()))
    }

    func testLoadTokenCallsCompletionWithErrorWhenClientReportsSuccessButResponseDataIsMalformed() throws {
        sut.loadToken(options: .any, completion: completion.callAsFunction)

        try client.simulateSuccess(data: makeMalformedResponseData())

        assertThat(completion.invocations.first, presentAnd(isFailure()))
    }

    func testLoadTokenReportsSuccessInCompletionWhenClientReportsAnHttpResponseWithStatusCodeWithin2xxRange() throws {
        sut.loadToken(options: .any, completion: completion.callAsFunction)

        let data = try makeSuccessResponseRawData(accessToken: .foo, expiringDate: "2025-06-09T02:09:00.000Z")
        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 200), data: data)
        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 299), data: data)
        let expectedDate = makeDate(year: 2025, month: 6, day: 9, hour: 2, minute: 9, second: 0)

        assertThat(completion.invocations, hasCount(2))
        assertThat(completion.invocations.first, presentAnd(isSuccess(withValue: equalTo(.init(accessToken: .foo, expirationDate: expectedDate)))))
        assertThat(completion.invocations.last, presentAnd(isSuccess(withValue: equalTo(.init(accessToken: .foo, expirationDate: expectedDate)))))
    }

    func testLoadTokenReportsErrorInCompletionWhenClientReportsAnHttpResponseWithStatusCodeOutside2xxRange() throws {
        sut.loadToken(options: .any, completion: completion.callAsFunction)

        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 199), data: Data())
        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 300), data: Data())

        assertThat(completion.invocations, hasCount(2))
        assertThat(completion.invocations.first, presentAnd(isFailure()))
        assertThat(completion.invocations.last, presentAnd(isFailure()))
    }

    // MARK: - Options

    func testOptionsEncodingBehavior() throws {
        let config = RestAccessTokenProvider.Options(userId: "user_identifier", expiresInSeconds: 123)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(config)
        let json = String(data: data, encoding: .utf8)
        let expected = """
        {"expires_in":123,"user_id":"user_identifier"}
        """

        assertThat(json, equalTo(expected))
    }

    // MARK: - AccessTokenResponse

    func testTokenLoadResponseDecodeWithValidPayload() throws {
        let json = """
        {
            "access_token": "__access_token__",
            "expires_at": "2025-06-09T02:09:00.000Z",
            "user_id": "user_xxx"
        }
        """
        let expectedDate = makeDate(year: 2025, month: 6, day: 9, hour: 2, minute: 9, second: 0)

        let decoded = try decode(json)

        assertThat(decoded.accessToken, equalTo("__access_token__"))
        assertThat(decoded.expirationDate, equalTo(expectedDate))
    }

    func testAccessTokenMissingShouldThrowAnException() {
        let json = """
        {
            "expires_at": "2025-06-09T02:09:00.000Z",
            "user_id": "user_xxx"
        }
        """

        assertThrows(try decode(json))
    }

    func testAccessTokenNullShouldThrowAnException() {
        let json = """
        {
            "access_token": null,
            "expires_at": "2025-06-09T02:09:00.000Z",
            "user_id": "user_xxx"
        }
        """

        assertThrows(try decode(json))
    }

    func testExpiresAtMissingShouldThrowAnException() {
        let json = """
        {
            "access_token": "__access_token__",
            "user_id": "user_xxx"
        }
        """

        assertThrows(try decode(json))
    }

    func testExpiresAtNullShouldThrowAnException() {
        let json = """
        {
            "access_token": "__access_token__",
            "expires_at": null,
            "user_id": "user_xxx"
        }
        """

        assertThrows(try decode(json))
    }

    func testExpiresAtWrongFormatShouldThrowAnException() {
        let json = """
        {
            "access_token": "__access_token__",
            "expires_at": "2025-06-09T02:09:00:00Z",
            "user_id": "user_xxx"
        }
        """

        assertThrows(try decode(json))
    }

    // MARK: - Helpers

    private func decode(_ json: String) throws -> RestAccessTokenProvider.AccessTokenResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy =  .formatted(DateFormatter.remoteApiFormatter)
        return try decoder.decode(RestAccessTokenProvider.AccessTokenResponse.self, from: Data(json.utf8))
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
        DateComponents(calendar: Calendar.current,
                       timeZone: .UTC,
                       era: nil,
                       year: year,
                       month: month,
                       day: day,
                       hour: hour,
                       minute: minute,
                       second: second,
                       nanosecond: 0,
                       weekday: nil,
                       weekdayOrdinal: nil,
                       quarter: nil,
                       weekOfMonth: nil,
                       weekOfYear: nil,
                       yearForWeekOfYear: nil).date!
    }

    private func makeSuccessResponseRawData(accessToken: String, expiringDate: String) throws -> Data {
        try JSONEncoder().encode( ["access_token" : accessToken, "expires_at": expiringDate, "user_id": "user_xxx"])
    }

    private func makeMalformedResponseData() throws -> Data {
        try JSONEncoder().encode( ["access_token" : "__access_token__", "expires_at": "2025-06-09T02:09:00:00Z", "user_id": "user_xxx"])
    }

    private func makeGarbageResponseData() throws -> Data {
        "garbage".data(using: .utf8)!
    }

    private func makeHttpUrlResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: [:])!
    }
}

private extension RestAccessTokenProvider.Options {

    static var any: RestAccessTokenProvider.Options = .init(userId: .alice, expiresInSeconds: 3600)
}
