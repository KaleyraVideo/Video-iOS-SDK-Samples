// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Config {

    enum Region: String, CaseIterable {
        case europe
        case india
        case us
        case middleEast
    }
}

extension Config.Region: Codable {}

extension Config.Region: LosslessStringConvertible {

    var description: String { rawValue }

    init?(_ rawValue: String) {
        switch rawValue.lowercased() {
            case "europe", "eu":
                self = .europe
            case "india", "in":
                self = .india
            case "us":
                self = .us
            case "middleeast", "me":
                self = .middleEast
            default:
                return nil
        }
    }
}

extension Config.Region {

    var availableEnvironments: [Config.Environment] {
        switch self {
            case .europe: Config.Environment.allCases
            case .india, .us, .middleEast: [.production]
        }
    }
}

extension Config.Region {

    var sdkRegion: KaleyraVideoSDK.Region {
        switch self {
            case .europe: .europe
            case .india: .india
            case .us: .us
            case .middleEast: .middleEast
        }
    }
}
