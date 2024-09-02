// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension Config {

    enum VoIP: Codable, Equatable {

        enum HandlingStrategy: Codable {
            case backgroundOnly
            case always
        }

        case disabled
        case manual(strategy: HandlingStrategy)
        case automatic(strategy: HandlingStrategy)

        var isAutomatic: Bool {
            if case VoIP.automatic = self {
                return true
            }
            return false
        }

        var isManual: Bool {
            if case VoIP.manual = self {
                return true
            }
            return false
        }

        var isDisabled: Bool {
            self == .disabled
        }

        var shouldListenForNotificationsInForeground: Bool {
            switch self {
                case .disabled:
                    return false
                case .manual(strategy: let strategy):
                    return strategy == .always
                case .automatic(strategy: let strategy):
                    return strategy == .always
            }
        }

        static let `default` = VoIP.automatic(strategy: .backgroundOnly)
    }
}
