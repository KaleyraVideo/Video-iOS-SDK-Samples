// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

enum Icons {

    static var logo256: UIImage? {
        .init(named: "logo256")
    }

    static var callkit: UIImage? {
        .init(named: "callkit-icon")
    }

    static var link: UIImage? {
        .init(systemName: "link")
    }

    static var linkBig: UIImage? {
        .init(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
    }

    static var qrCode: UIImage? {
        .init(systemName: "qrcode")
    }

    static var contact: UIImage? {
        .init(systemName: "person.crop.circle")
    }

    static var settings: UIImage? {
        .init(systemName: "gear")
    }

    static var phone: UIImage? {
        .init(systemName: "phone")
    }

    static var redLine: UIImage? {
        .init(named: "red line")
    }

    static var videoCallAction: UIImage? {
        .init(systemName: "video")
    }

    static var chatAction: UIImage? {
        .init(systemName: "message")
    }

    static var logShortcut: UIApplicationShortcutIcon? {
        .init(systemImageName: "ladybug")
    }
}
