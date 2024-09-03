// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

struct Config: Codable {

    static var logLevel: LogLevel = .all

    let keys: Config.Keys
    let environment: Config.Environment
    let region: Config.Region
    let showUserInfo: Bool
    let disableDirectIncomingCalls: Bool
    let voip: Config.VoIP
    let tools: Config.Tools
    let cameraPosition: Config.CameraPosition

    init(keys: Config.Keys,
         showUserInfo: Bool = true,
         environment: Config.Environment = .sandbox,
         region: Config.Region = .europe,
         disableDirectIncomingCalls: Bool = false,
         voip: Config.VoIP = .default,
         tools: Config.Tools = .init(),
         cameraPosition: Config.CameraPosition = .front) {
        self.keys = keys
        self.environment = environment
        self.region = region
        self.showUserInfo = showUserInfo
        self.disableDirectIncomingCalls = disableDirectIncomingCalls
        self.voip = voip
        self.tools = tools
        self.cameraPosition = cameraPosition
    }

    // MARK: - Decodable

    private enum CodingKeys: CodingKey {
        case keys
        case environment
        case region
        case showUserInfo
        case disableDirectIncomingCalls
        case voip
        case tools
        case cameraPosition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keys = try container.decode(Config.Keys.self, forKey: .keys)
        self.environment = try container.decode(Environment.self, forKey: .environment)
        self.region = try container.decodeIfPresent(Config.Region.self, forKey: .region) ?? .europe
        self.showUserInfo = try container.decode(Bool.self, forKey: .showUserInfo)
        self.disableDirectIncomingCalls = try container.decodeIfPresent(Bool.self, forKey: .disableDirectIncomingCalls) ?? false
        self.voip = try container.decodeIfPresent(Config.VoIP.self, forKey: .voip) ?? .automatic(strategy: .backgroundOnly)
        self.tools = try container.decode(Config.Tools.self, forKey: .tools)
        self.cameraPosition = try container.decodeIfPresent(Config.CameraPosition.self, forKey: .cameraPosition) ?? .front
    }
}