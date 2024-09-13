// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension Config: Codable {

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

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keys, forKey: .keys)
        try container.encode(environment, forKey: .environment)
        try container.encode(region, forKey: .region)
        try container.encode(showUserInfo, forKey: .showUserInfo)
        try container.encode(disableDirectIncomingCalls, forKey: .disableDirectIncomingCalls)
        try container.encode(voip, forKey: .voip)
    }
}
