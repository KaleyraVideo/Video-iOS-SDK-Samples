// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

final class RestAccessTokenProvider: AccessTokenProvider {

    private let client: HTTPClient
    private let config: Config

    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.remoteApiFormatter)
        return decoder
    }()

    init(client: HTTPClient, config: Config) {
        self.client = client
        self.config = config
    }

    func provideAccessToken(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        loadToken(options: .init(userId: userId, expiresInSeconds: 10 * 60)) { result in
            completion(result.map(\.accessToken))
        }
    }

    func loadToken(options: Options, completion: @escaping (Result<RestAccessTokenProvider.AccessTokenResponse, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "/v2/sdk/credentials", relativeTo: config.apiURL)!)
        request.httpBody = try? JSONEncoder().encode(options)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let decoder = jsonDecoder
        client.post(request) { result in
            completion(Result {
                let response = try result.get()
                if response.httpResponse.hasSuccessfulStatusCode {
                    return try decoder.decode(RestAccessTokenProvider.AccessTokenResponse.self, from: response.data)
                } else {
                    throw AccessTokenLoadFailure()
                }
            })
        }
    }

    private struct AccessTokenLoadFailure: Error {}

    struct Options: Encodable {

        private enum CodingKeys: String, CodingKey {
            case user_id
            case expires_in
        }

        let userId: String
        let expiresInSeconds: UInt

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userId, forKey: .user_id)
            try container.encode(expiresInSeconds, forKey: .expires_in)
        }
    }

    struct AccessTokenResponse: Equatable, Decodable {

        private enum CodingKeys: String, CodingKey {
            case access_token
            case expires_at
        }

        let accessToken: String
        let expirationDate: Date

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.accessToken = try container.decode(String.self, forKey: .access_token)
            self.expirationDate = try container.decode(Date.self, forKey: .expires_at)
        }

        init(accessToken: String, expirationDate: Date) {
            self.accessToken = accessToken
            self.expirationDate = expirationDate
        }
    }
}
