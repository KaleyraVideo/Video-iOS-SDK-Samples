// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension Config {

    enum CameraPosition: String, Codable, CustomStringConvertible, CaseIterable {
        case front
        case back

        var description: String {
            rawValue
        }
    }
}
