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

    static var callSettings: UIImage? {
        .init(named: "callSettings")
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

    @available(iOS 15.0, *)
    static var end: UIImage? {
        .init(named: "end-call", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var micOff: UIImage? {
        .init(named: "mic-off", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var cameraOff: UIImage? {
        .init(named: "camera-off", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var flipCamera: UIImage? {
        .init(named: "flipcam", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var cameraEffects: UIImage? {
        .init(named: "virtual-background", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var speakerOn: UIImage? {
        .init(named: "speaker-on", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var fileShare: UIImage? {
        .init(named: "file-share", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var screenShare: UIImage? {
        .init(named: "screen-share", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var chat: UIImage? {
        .init(named: "chat", in: .sdk, compatibleWith: nil)
    }

    @available(iOS 15.0, *)
    static var whiteboard: UIImage? {
        .init(named: "whiteboard", in: .sdk, compatibleWith: nil)
    }

    static var addButton: UIImage {
        .init(systemName: "plus")!
    }

    static var questionMark: UIImage {
        .init(systemName: "questionmark")!
    }

    static var removeButton: UIImage {
        .init(systemName: "minus.circle.fill")!
    }
}
