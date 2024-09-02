// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class RestUserRepositoryTests: UnitTestCase, CompletionSpyFactory {

    private var sut: RestUserRepository!
    private var client: HTTPClientMock!
    private var completion: CompletionSpy<Result<[String], Error>>!

    override func setUp() {
        super.setUp()

        client = .init()
        completion = makeCompletionSpy()
        sut = .init(client: client, config: .init(keys: .any, showUserInfo: true, environment: .sandbox))
    }

    override func tearDown() {
        sut = nil
        client = nil
        completion = nil

        super.tearDown()
    }

    func testLoadUsersCallCompletionWithErrorWhenClientReportsFailure() throws {
        sut.loadUsers(completion: completion.callAsFunction)

        try client.simulateFailure(error: anyNSError())

        assertThat(completion.invocations.first, presentAnd(isFailure()))
    }

    func testLoadUsersCallCompletionWithUserIdsWhenClientReportsSuccess() throws {
        sut.loadUsers(completion: completion.callAsFunction)

        try client.simulateSuccess(data: makeSuccessResponseRawData(users: [.alice, .bob]))

        assertThat(completion.invocations.first, presentAnd(isSuccess(withValue: equalTo([.alice, .bob]))))
    }

    func testLoadUsersCallsCompletionWithErrorWhenClientReportsSuccessButDecodingFails() throws {
        sut.loadUsers(completion: completion.callAsFunction)

        try client.simulateSuccess(data: makeGarbageResponseData())

        assertThat(completion.invocations.first, presentAnd(isFailure()))
    }

    func testLoadUsersCallsCompletionWithErrorWhenClientReportsSuccessBut() throws {
        sut.loadUsers(completion: completion.callAsFunction)

        try client.simulateSuccess(data: makeMalformedResponseData())

        assertThat(completion.invocations.first, presentAnd(isFailure()))
    }

    func testLoadUsersReportsSuccessInCompletionWhenClientReportsAnHttpResponseWithStatusCodeWithin2xxRange() throws {
        sut.loadUsers(completion: completion.callAsFunction)

        let data = try makeSuccessResponseRawData(users: [.alice, .bob])
        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 200), data: data)
        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 299), data: data)

        assertThat(completion.invocations, hasCount(2))
        assertThat(completion.invocations.first, presentAnd(isSuccess(withValue: equalTo([.alice, .bob]))))
        assertThat(completion.invocations.last, presentAnd(isSuccess(withValue: equalTo([.alice, .bob]))))
    }

    func testLoadUsersReportsErrorInCompletionWhenClientReportsAnHttpResponseWithStatusCodeOutside2xxRange() throws {
        sut.loadUsers(completion: completion.callAsFunction)

        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 199), data: Data())
        try client.simulateSuccess(httpResponse: makeHttpUrlResponse(statusCode: 300), data: Data())

        assertThat(completion.invocations, hasCount(2))
        assertThat(completion.invocations.first, presentAnd(isFailure()))
        assertThat(completion.invocations.last, presentAnd(isFailure()))
    }

    // MARK: - Helpers

    private func makeSuccessResponseRawData(users: [String]) throws -> Data {
        try JSONEncoder().encode(RestUserRepository.PaginatedResponse(users: users.map({ .init(id: $0) }), offset: 0, limit: 0, hasMore: false, count: 2))
    }

    private func makeGarbageResponseData() throws -> Data {
        "garbage".data(using: .utf8)!
    }

    private func makeMalformedResponseData() throws -> Data {
        try JSONEncoder().encode( ["malformed" : ["foo", "bar"]])
    }

    private func makeHttpUrlResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: [:])!
    }
}
