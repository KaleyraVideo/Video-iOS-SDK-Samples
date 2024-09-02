// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

extension Config {

    struct Keys: Hashable, Codable {
        let apiKey: ApiKey
        let appId: AppId
    }

    struct ApiKey: Hashable, Codable, CustomStringConvertible {

        private let raw: String

        var description: String { raw }

        init(_ string: String) throws {
            let trimmed = string.trimmingWhitespacesAndNewLines
            guard trimmed.matches("^ak_(?:live|test)_[a-zA-Z0-9]{12,}$") else { throw InvalidApiKeyError() }
            self.raw = trimmed
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            try self.init(try container.decode(String.self))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(raw)
        }
    }

    struct AppId: Hashable, Codable, CustomStringConvertible {

        private let raw: String

        var description: String { raw }

        init(_ string: String) throws {
            let trimmed = string.trimmingWhitespacesAndNewLines
            guard trimmed.matches("^mAppId_[a-zA-Z0-9]{12,}$") else { throw InvalidAppIdError() }
            self.raw = trimmed
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            try self.init(try container.decode(String.self))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(raw)
        }
    }
}
