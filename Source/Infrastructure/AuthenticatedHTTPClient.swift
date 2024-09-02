// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class AuthenticatedHTTPClient: HTTPClient {

    private let client: HTTPClient
    private let token: String

    init(client: HTTPClient, token: String) {
        self.client = client
        self.token = token
    }

    func get(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        client.get(makeAuthenticatedRequest(request), completion: completion)
    }

    func post(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        client.post(makeAuthenticatedRequest(request), completion: completion)
    }

    private func makeAuthenticatedRequest(_ request: URLRequest) -> URLRequest {
        var authenticatedRequest = request
        authenticatedRequest.addValue(token, forHTTPHeaderField: "apikey")
        return authenticatedRequest
    }
}
