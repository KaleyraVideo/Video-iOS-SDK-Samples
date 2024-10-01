// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension Bundle {

    @available(iOS 15.0, *)
    static let sdk: Bundle = Bundle(for: KaleyraVideo.self)

    var version: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var build: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
