// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

extension Config.Keys {

    static let any = Config.Keys(apiKey: validApiKey, appId: validAppId)

    static let validAppId: Config.AppId = try! .init("mAppId_32d6da9f24c1b7s01bd2c61a")
    static let validApiKey: Config.ApiKey = try! .init("ak_live_18ad4c1f9dae593b114b6e3f")
    static let validAppId2: Config.AppId = try! .init("mAppId_32d6da9f24c1b7s01bd2c61b")
    static let validApiKey2: Config.ApiKey = try! .init("ak_live_18ad4c1f9dae593b114b6e2f")
}
