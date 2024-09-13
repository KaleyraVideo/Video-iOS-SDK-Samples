// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

struct Config: Codable {

    static var logLevel: LogLevel = .all

    var keys: Config.Keys
    var environment: Config.Environment
    var region: Config.Region
    var showUserInfo: Bool
    var disableDirectIncomingCalls: Bool
    var voip: Config.VoIP

    init(keys: Config.Keys,
         showUserInfo: Bool = true,
         environment: Config.Environment = .sandbox,
         region: Config.Region = .europe,
         disableDirectIncomingCalls: Bool = false,
         voip: Config.VoIP = .default) {
        self.keys = keys
        self.environment = environment
        self.region = region
        self.showUserInfo = showUserInfo
        self.disableDirectIncomingCalls = disableDirectIncomingCalls
        self.voip = voip
    }

    // MARK: - Decodable

    private enum CodingKeys: CodingKey {
        case keys
        case environment
        case region
        case showUserInfo
        case disableDirectIncomingCalls
        case voip
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keys = try container.decode(Config.Keys.self, forKey: .keys)
        self.environment = try container.decode(Environment.self, forKey: .environment)
        self.region = try container.decodeIfPresent(Config.Region.self, forKey: .region) ?? .europe
        self.showUserInfo = try container.decode(Bool.self, forKey: .showUserInfo)
        self.disableDirectIncomingCalls = try container.decodeIfPresent(Bool.self, forKey: .disableDirectIncomingCalls) ?? false
        self.voip = try container.decodeIfPresent(Config.VoIP.self, forKey: .voip) ?? .automatic(strategy: .backgroundOnly)
    }
}
