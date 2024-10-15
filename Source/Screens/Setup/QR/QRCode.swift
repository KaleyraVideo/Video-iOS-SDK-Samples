// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

struct QRCode {

    let config: Config
    let userAlias: String?
    let callType: KaleyraVideoSDK.CallOptions.CallType?

    // MARK: - Parsing

    enum ParseError: Error {
        case cannotSplitURLIntoComponents
        case missingRequiredConfigurationArguments
        case invalidEnvironment
        case invalidRegion
        case invalidAppId
        case invalidApiKey
    }

    fileprivate enum Key: String {
        case apiKey
        case appId
        case environment
        case region
        case userAlias
        case callType = "defaultCallType"
    }

    static func parse(from url: URL) throws -> QRCode {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ParseError.cannotSplitURLIntoComponents
        }

        guard let queryItems = components.queryItems else {
            throw ParseError.missingRequiredConfigurationArguments
        }

        do {
            let appId = try Config.AppId(queryItems[.appId])
            let apiKey = try Config.ApiKey(queryItems[.apiKey])

            let userAlias = queryItems[.userAlias]

            return .init(config: .init(keys: .init(apiKey: apiKey, appId: appId),
                                       environment: try parseEnvironment(queryItems[.environment]),
                                       region: try parseRegion(queryItems[.region])),
                         userAlias: userAlias,
                         callType: .init(rawValue: queryItems[.callType]))
        } catch is InvalidAppIdError {
            throw ParseError.invalidAppId
        } catch is InvalidApiKeyError {
            throw ParseError.invalidApiKey
        }
    }

    private static func parseEnvironment(_ string: String) throws -> Config.Environment {
        guard let env = Config.Environment(string) else {
            throw ParseError.invalidEnvironment
        }
        return env
    }

    private static func parseRegion(_ string: String) throws -> Config.Region {
        guard let region = Config.Region(string) else {
            throw ParseError.invalidRegion
        }
        return region
    }
}

private extension Array where Element == URLQueryItem {

    subscript(_ key: QRCode.Key) -> String {
        first(where: { $0.name == key })?.value ?? ""
    }
}

private extension String {

    static func == <T: RawRepresentable>(lhs: String, rhs: T) -> Bool where T.RawValue == String {
        lhs == rhs.rawValue
    }
}

private extension KaleyraVideoSDK.CallOptions.CallType {

    init?(rawValue: String) {
        switch rawValue.lowercased() {
            case "audio_video", "audiovideo" :
                self = .audioVideo
            case "audio_upgradable", "audioupgradable":
                self = .audioUpgradable
            case "audio_only", "audioonly":
                self = .audioOnly
            default:
                return nil
        }
    }
}
