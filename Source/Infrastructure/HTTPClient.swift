// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

protocol HTTPClient {

    typealias Result = Swift.Result<(data: Data, httpResponse: HTTPURLResponse), Error>

    func get(_ request: URLRequest, completion: @escaping (Result) -> Void)
    func post(_ request: URLRequest, completion: @escaping (Result) -> Void)
}
