// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraTestHelpers

protocol QRCodeFixtureFactory {

    func makeMalformedStringConfiguration() -> URL
    func makeValidConfiguration(userId: String, environment: String, region: String, appId: String, apiKey: String, callType: String) -> URL
}

extension QRCodeFixtureFactory {

    func makeMalformedStringConfiguration() -> URL {
        return anyURL()
    }

    func makeValidConfiguration(userId: String = "alice",
                                environment: String = "sandbox",
                                region: String = "eu",
                                appId: String = "mAppId_0000000000000000",
                                apiKey: String = "ak_test_000000000000000",
                                callType: String = "AUDIO_VIDEO") -> URL {
        var urlString = "https://www.bandyer.com/"
        urlString += "?userAlias=\(userId)"
        urlString += "&environment=\(environment)"
        urlString += "&region=\(region)"
        urlString += "&appId=\(appId)"
        urlString += "&apiKey=\(apiKey)"
        urlString += "&defaultCallType=\(callType)"
        return URL(string: urlString)!
    }
}
