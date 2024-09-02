// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Config {

    enum Region: String, Codable, CustomStringConvertible, CaseIterable {
        case europe
        case india
        case us
        case middleEast

        init?(rawValue: String) {
            switch rawValue.lowercased() {
                case "europe", "eu":
                    self = .europe
                case "india", "in":
                    self = .india
                case "us":
                    self = .us
                case "middleEast", "me":
                    self = .middleEast
                default:
                    return nil
            }
        }

        var description: String {
            rawValue
        }
    }
}

extension Config.Region {

    var sdkRegion: KaleyraVideoSDK.Region {
        switch self {
            case .europe:
                return .europe
            case .india:
                return .india
            case .us:
                return .us
            case .middleEast:
                return .middleEast
        }
    }
}
