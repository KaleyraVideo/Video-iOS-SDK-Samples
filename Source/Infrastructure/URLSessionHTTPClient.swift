// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class URLSessionHTTPClient: HTTPClient {

    private struct UnsupportedResponseError: Error {}

    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        startTask(request, completion: completion)
    }

    func post(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        var postRequest = request
        postRequest.httpMethod = "POST"
        startTask(postRequest, completion: completion)
    }

    private func startTask(_ request: URLRequest,
                         completion: @escaping (HTTPClient.Result) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnsupportedResponseError()
                }
            })
        }
        task.resume()
    }
}
