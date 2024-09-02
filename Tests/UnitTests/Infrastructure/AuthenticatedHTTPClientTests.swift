// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class AuthenticatedHTTPClientTests: UnitTestCase {

    private var client: HTTPClientMock!
    private var sut: AuthenticatedHTTPClient!
    private let token = "a token"

    override func setUpWithError() throws {
        try super.setUpWithError()

        client = .init()
        sut = .init(client: client, token: token)
    }

    override func tearDownWithError() throws {
        sut = nil
        client = nil

        try super.tearDownWithError()
    }

    func testGetAppendsTheTokenProvidedInTheRequestHeaders() throws {
        sut.get(makeAnyRequest()) { _ in }

        assertThat(client.requests.first?.request.allHTTPHeaderFields, presentAnd(hasEntry(equalTo("apikey"), equalTo(token))))
    }

    func testGetReportsResultInCompletionWhenDecoratedClientReportsResult() throws {
        let completion = makeCompletionSpy()
        sut.get(makeAnyRequest(), completion: completion.callAsFunction)

        try client.simulate(result: .failure(anyNSError()))

        assertThat(completion.invocations.first, presentAnd(isFailure(withError: instanceOfAnd(equalTo(anyNSError())))))
    }

    func testPostAppendsTheTokenProvidedByTheTokenProviderInTheRequestHeaders() throws {
        sut.post(.init(url: anyURL())) { _ in }

        assertThat(client.requests.first?.request.allHTTPHeaderFields, presentAnd(hasEntry(equalTo("apikey"), equalTo(token))))
    }

    func testPostReportsResultInCompletionWhenDecoratedClientReportsResult() throws {
        let completion = makeCompletionSpy()
        sut.post(.init(url: anyURL()), completion: completion.callAsFunction)

        try client.simulate(result: .failure(anyNSError()))

        assertThat(completion.invocations.first, presentAnd(isFailure(withError: instanceOfAnd(equalTo(anyNSError())))))
    }

    func testPostWithHeadersAppendsTheTokenProvidedByTheTokenProviderInTheRequestHeaders() throws {
        var request = URLRequest(url: anyURL())
        request.addValue("test", forHTTPHeaderField: "header")
        sut.post(request) { _ in }

        assertThat(client.requests.first?.request.allHTTPHeaderFields, presentAnd(hasEntry(equalTo("apikey"), equalTo(token))))
    }

    func testPostWithHeadersReportsResultInCompletionWhenDecoratedClientReportsResult() throws {
        let completion = makeCompletionSpy()
        var request = URLRequest(url: anyURL())
        request.addValue("test", forHTTPHeaderField: "header")
        sut.post(request, completion: completion.callAsFunction)

        try client.simulate(result: .failure(anyNSError()))

        assertThat(completion.invocations.first, presentAnd(isFailure(withError: instanceOfAnd(equalTo(anyNSError())))))
    }

    // MARK: - Helpers

    private func makeAnyRequest() -> URLRequest {
        URLRequest(url: anyURL())
    }

    private func makeCompletionSpy() -> CompletionSpy<HTTPClient.Result> {
        .init()
    }
}

