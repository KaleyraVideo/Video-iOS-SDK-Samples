// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class RestPushTokenRepository: PushTokenRepository {

    private enum RegistarError: Error {
        case invalidRequestURL
        case unsuccessfulResponse
    }

    private let client: HTTPClient
    private let config: Config

    init(client: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)), config: Config) {
        self.client = client
        self.config = config
    }

    func registerToken(request: PushTokenRegistrationRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            sendRequest(try makeURLRequest(from: request), completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    func deregisterToken(request: PushTokenDeregistrationRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            sendRequest(try makeURLRequest(from: request), completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    private func sendRequest(_ request: URLRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        client.get(request) { (result) in
            completion(Result {
                let response = try result.get()
                guard response.httpResponse.hasSuccessfulStatusCode else {
                    throw RegistarError.unsuccessfulResponse
                }
                return
            })
        }
    }

    private func makeURLRequest(from registrationRequest: PushTokenRegistrationRequest) throws -> URLRequest {
        let path = "/mobile_push_notifications/rest/device"
        guard let url = URL(string: path, relativeTo: config.baseURL) else { throw RegistarError.invalidRequestURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(RegisterTokenRequestBody(request: registrationRequest, appId: config.keys.appId))

        return request
    }

    private func makeURLRequest(from registrationRequest: PushTokenDeregistrationRequest) throws -> URLRequest {
        let path = "/mobile_push_notifications/rest/device/" + registrationRequest.userID + "/" + config.keys.appId.description + "/" + registrationRequest.token

        guard let url = URL(string: path, relativeTo: config.baseURL) else { throw RegistarError.invalidRequestURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return request
    }

    // MARK: - Request

    private struct RegisterTokenRequestBody: Encodable {

        enum TokenType: String, Encodable {
            case voip
            case alert
        }

        let alias: String
        let appId: Config.AppId
        let token: String
        let tokenType: TokenType
#if DEBUG
        let production = false
#else
        let production = true
#endif

        init(alias: String, appId: Config.AppId, token: String, tokenType: TokenType) {
            self.alias = alias
            self.appId = appId
            self.token = token
            self.tokenType = tokenType
        }

        init(request: PushTokenRegistrationRequest, appId: Config.AppId) {
            self.init(alias: request.userID, appId: appId, token: request.token, tokenType: request.isVoip ? .voip : .alert)
        }

        private enum CodingKeys: CodingKey {
            case user_alias
            case app_id
            case push_token
            case push_type
            case platform
            case production
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(alias, forKey: .user_alias)
            try container.encode(appId, forKey: .app_id)
            try container.encode(token, forKey: .push_token)
            try container.encode(tokenType, forKey: .push_type)
            try container.encode("ios", forKey: .platform)
            try container.encode(production, forKey: .production)
        }
    }
}
