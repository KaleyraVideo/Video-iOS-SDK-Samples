//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation

class RestUserRepository {

    private let apiKey: String
    private let url: URL?
    private var task: URLSessionDataTask?

    var queue: DispatchQueue

    var isFetching: Bool {
        guard let t = task else {
            return false
        }

        return t.state != .completed
    }

    init() {
        apiKey = Constants.ApiKey
        url = URL(string: "REST URL")
        queue = DispatchQueue.main
    }

    func fetchAllUsers(_ completion: @escaping ([String]?, Error?) -> Void) {

        precondition(url != nil, "An url must be provided")

        guard !isFetching else {
            queue.async {
                completion(nil, NSError(domain: "com.acme.error", code: 1, userInfo: [NSLocalizedFailureReasonErrorKey: "Already fetching users"]))
            }
            return
        }

        var request = URLRequest(url: url!)
        request.addValue(apiKey, forHTTPHeaderField: "apikey")

        self.task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in

            guard let data = data, error == nil else {
                self.queue.async {
                    completion(nil, NSError(domain: "com.acme.error", code: 2, userInfo: [NSLocalizedFailureReasonErrorKey: "An error occurred while fetching users", NSUnderlyingErrorKey: error!]))
                }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data)

                self.queue.async {
                    let decodedData = json as? [String: [String]]
                    completion(decodedData?["user_id_list"], nil)
                }
            } catch {
                self.queue.async {
                    completion(nil, NSError(domain: "com.acme.error", code: 3, userInfo: [NSLocalizedFailureReasonErrorKey: "An error occurred while parsing users"]))
                }
            }
        }

        task?.resume()
    }
}
