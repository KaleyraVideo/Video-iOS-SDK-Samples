// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Config {

    enum Environment: String, Codable, CustomStringConvertible, CaseIterable {
        case production
        case sandbox
        case development

        init?(rawValue: String) {
            switch rawValue.lowercased() {
                case "production", "prod":
                    self = .production
                case "sandbox":
                    self = .sandbox
                case "develop", "development":
                    self = .development
                default:
                    return nil
            }
        }

        var description: String {
            rawValue
        }

        static func environmentsFor(region: Region) -> [Environment] {
            switch region {
                case .europe:
                    return Environment.allCases
                case .india:
                    return [.production]
                case .us:
                    return [.production]
                case .middleEast:
                    return [.production]
            }
        }
    }
}

extension Config.Environment {

    var sdkEnvironment: KaleyraVideoSDK.Environment {
        switch self {
            case .production:
                return .production
            case .sandbox:
                return .sandbox
#if DEBUG
            case .development:
                return .develop
#else
            case .development:
                return .init("develop")
#endif

        }
    }
}
