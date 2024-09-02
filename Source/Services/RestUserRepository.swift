// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class RestUserRepository: UserRepository {

    private struct UnsuccessfulResponseError: Error {}

    private let client: HTTPClient
    private let config: Config
    private let decoder: JSONDecoder
    private static let limit: UInt = 100

    init(client: HTTPClient, config: Config) {
        self.client = client
        self.config = config
        self.decoder = .init()
    }

    func loadUsers(completion: @escaping (Result<[String], Error>) -> Void) {
        recursiveLoadUsers(users: [], nextPage: .init(offset: 0, limit: Self.limit), completion: completion)
    }

    private func recursiveLoadUsers(users: [String], nextPage: Page.NextPage, completion: @escaping (Result<[String], Error>) -> Void) {
        load(page: nextPage) { [weak self] result in
            guard let self = self else { return }

            do {
                var newUsers = users
                let page = try result.get()
                newUsers.append(contentsOf: page.users)
                if let nextPage = page.nextPage {
                    recursiveLoadUsers(users: newUsers, nextPage: nextPage, completion: completion)
                } else {
                    completion(.success(newUsers))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func load(page: Page.NextPage, completion: @escaping (Result<Page, Error>) -> Void) {
        let path = "/v2/users"
        let url = URL(string: path, relativeTo: config.apiURL)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        var queryItems = [URLQueryItem]()
        queryItems.append(.init(name: "offset", value: String(page.offset)))
        queryItems.append(.init(name: "limit", value: String(page.limit)))
        components?.queryItems = queryItems

        var request = URLRequest(url: components!.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        client.get(request) { [weak self] result in
            guard let self = self else { return }

            do {
                let response = try result.get()

                if response.httpResponse.hasSuccessfulStatusCode {
                    let response = try self.decoder.decode(PaginatedResponse.self, from: response.data)
                    completion(.success(.init(users: response.users.map(\.id), nextPage: response.hasMore ? .init(offset: page.offset + Self.limit, limit: Self.limit) : nil)))
                } else if response.httpResponse.statusCode == 429 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 60) { [weak self] in
                        self?.load(page: page, completion: completion)
                    }
                } else {
                    completion(.failure(UnsuccessfulResponseError()))
                }
            } catch {
                completion(.failure(UnsuccessfulResponseError()))
            }
        }
    }

    private struct Page {
        struct NextPage {
            let offset: UInt
            let limit: UInt
        }

        let users: [String]
        let nextPage: NextPage?
    }


    struct PaginatedResponse: Codable {

        struct RemoteUser: Codable {

            let id: String
            let avatarURL: URL?

            private enum CodingKeys: String, CodingKey {
                case id
                case avatar_url
            }

            init(id: String, avatarURL: URL? = nil) {
                self.id = id
                self.avatarURL = avatarURL
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decode(String.self, forKey: .id)
                self.avatarURL = (try container.decodeIfPresent(String.self, forKey: .avatar_url)).map({ .init(string: $0) }) ?? nil
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encodeIfPresent(avatarURL?.absoluteString, forKey: .avatar_url)
            }
        }

        let users: [RemoteUser]
        let offset: UInt
        let limit: UInt
        let hasMore: Bool
        let count: UInt

        private enum CodingKeys: String, CodingKey {
            case users
            case offset
            case limit
            case has_more
            case count
        }

        init(users: [RemoteUser], offset: UInt, limit: UInt, hasMore: Bool, count: UInt) {
            self.users = users
            self.offset = offset
            self.limit = limit
            self.hasMore = hasMore
            self.count = count
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.users = try container.decode([RemoteUser].self, forKey: .users)
            self.offset = try container.decode(UInt.self, forKey: .offset)
            self.limit = try container.decode(UInt.self, forKey: .limit)
            self.count = try container.decode(UInt.self, forKey: .count)
            self.hasMore = try container.decode(Bool.self, forKey: .has_more)
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(users, forKey: .users)
            try container.encode(offset, forKey: .offset)
            try container.encode(limit, forKey: .limit)
            try container.encode(hasMore, forKey: .has_more)
            try container.encode(count, forKey: .count)
        }
    }
}
