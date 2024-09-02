// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class HTTPClientMock: HTTPClient {

    enum HTTPClientStubError: Error, Equatable {
        case didNotCallGetError
        case dummyError
    }

    private(set) var requests = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    private var lastRequest: (request: URLRequest, completion: (HTTPClient.Result) -> Void)?

    func get(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        requests.append((request, completion))
        lastRequest = (request, completion)
    }

    func simulate(result: HTTPClient.Result) throws {
        guard !requests.isEmpty else { throw HTTPClientMock.HTTPClientStubError.didNotCallGetError }
        requests.forEach { $0.completion(result) }
    }

    func simulateSuccess(data: Data) throws {
        let httpResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!
        try simulate(result: .success((data, httpResponse)))
    }

    func simulateFailure(error: Error) throws {
        try simulate(result: .failure(error))
    }

    func simulateSuccess(httpResponse: HTTPURLResponse, data: Data) throws {
        try simulate(result: .success((data, httpResponse)))
    }

    func post(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        requests.append((request, completion))
        lastRequest = (request, completion)
    }
}
