// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct QRCode {

    enum CallType: String, Codable {
        case audio_video = "AUDIO_VIDEO"
        case audio_upgradable = "AUDIO_UPGRADABLE"
        case audio_only = "AUDIO_ONLY"
    }

    let keys: Config.Keys
    let userAlias: String?
    let environment: Config.Environment
    let region: Config.Region
    let defaultCallType: CallType?

    func makeConfig() -> Config {
        .init(keys: keys, environment: environment, region: region)
    }

    // MARK: - Parsing

    enum ParseError: Error {
        case cannotSplitURLIntoComponents
        case missingRequiredConfigurationArguments
        case invalidEnvironment
        case invalidRegion
        case invalidAppId
        case invalidApiKey
    }

    static func parse(from url: URL) throws -> QRCode {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ParseError.cannotSplitURLIntoComponents
        }

        guard let queryItems = components.queryItems,
              let rawApiKey = queryItems.first(where: { $0.name == "apiKey" })?.value,
              let rawAppId = queryItems.first(where: { $0.name == "appId" })?.value,
              let env = queryItems.first(where: { $0.name == "environment" })?.value,
              let reg = queryItems.first(where: { $0.name == "region" })?.value else {
            throw ParseError.missingRequiredConfigurationArguments
        }

        do {
            let appId = try Config.AppId(rawAppId)
            let apiKey = try Config.ApiKey(rawApiKey)

            let userAlias = queryItems.first(where: { $0.name == "userAlias" })?.value
            let callTypeString = queryItems.first(where: { $0.name == "defaultCallType" })?.value

            return .init(keys: .init(apiKey: apiKey, appId: appId),
                         userAlias: userAlias,
                         environment: try parseEnvironment(env),
                         region: try parseRegion(reg),
                         defaultCallType: CallType(rawValue: callTypeString ?? ""))
        } catch is InvalidAppIdError {
            throw ParseError.invalidAppId
        } catch is InvalidApiKeyError {
            throw ParseError.invalidApiKey
        }
    }

    private static func parseEnvironment(_ string: String) throws -> Config.Environment {
        guard let env = Config.Environment(rawValue: string) else {
            throw ParseError.invalidEnvironment
        }
        return env
    }

    private static func parseRegion(_ string: String) throws -> Config.Region {
        guard let region = Config.Region(rawValue: string) else {
            throw ParseError.invalidRegion
        }
        return region
    }
}
