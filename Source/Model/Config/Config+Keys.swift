// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

extension Config {

    struct Keys: Hashable, Codable {
        let apiKey: ApiKey
        let appId: AppId
    }

    struct ApiKey: Hashable, SecretKey {

        let rawValue: String

        init(_ rawValue: String) throws {
            let trimmed = rawValue.trimmingWhitespacesAndNewLines
            guard trimmed.matches("^ak_(?:live|test)_[a-zA-Z0-9]{12,}$") else { throw InvalidApiKeyError() }
            self.rawValue = trimmed
        }
    }

    struct AppId: Hashable, SecretKey {

        let rawValue: String

        init(_ rawValue: String) throws {
            let trimmed = rawValue.trimmingWhitespacesAndNewLines
            guard trimmed.matches("^mAppId_[a-zA-Z0-9]{12,}$") else { throw InvalidAppIdError() }
            self.rawValue = trimmed
        }
    }
}

protocol SecretKey: CustomStringConvertible, Codable {

    var rawValue: String { get }

    init(_ rawValue: String) throws
}

extension SecretKey {

    var description: String { rawValue }
}

extension SecretKey {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
