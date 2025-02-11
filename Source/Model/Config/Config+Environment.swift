// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Config {

    enum Environment: String, CaseIterable {
        case production
        case sandbox
        case development
    }
}

extension Config.Environment: LosslessStringConvertible {

    var description: String { rawValue }

    init?(_ rawValue: String) {
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
}

extension Config.Environment: Codable {}

extension Config.Environment {

    var sdkEnvironment: KaleyraVideoSDK.Environment {
        switch self {
            case .production: .production
            case .sandbox: .sandbox
            case .development: .init("develop")
        }
    }
}
