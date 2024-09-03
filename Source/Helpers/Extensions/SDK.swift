// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

protocol SDK {

    static var logLevel: KaleyraVideoSDK.LogLevel { get set }
    static var loggers: KaleyraVideoSDK.Loggers { get set }
}

extension KaleyraVideo: SDK {}
