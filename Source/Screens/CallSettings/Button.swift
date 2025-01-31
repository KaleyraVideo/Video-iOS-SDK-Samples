// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

@available(iOS 15.0, *)
internal enum Button: Equatable, CaseIterable {
    case hangUp
    case microphone
    case camera
    case flipCamera
    case cameraEffects
    case audioOutput
    case fileShare
    case screenShare
    case chat
    case whiteboard
}

@available(iOS 15.0, *)
extension Button {

    var identifier: String {
        switch self {
            case .hangUp: "hangUp"
            case .microphone: "microphone"
            case .camera: "camera"
            case .flipCamera: "flip"
            case .cameraEffects: "effects"
            case .audioOutput: "audio"
            case .fileShare: "file"
            case .screenShare: "screenshare"
            case .chat: "chat"
            case .whiteboard: "whiteboard"
        }
    }

    init?(identifier: String) {
        switch identifier.lowercased() {
            case "hangup":
                self = .hangUp
            case "microphone":
                self = .microphone
            case "camera":
                self = .camera
            case "flip":
                self = .flipCamera
            case "effects":
                self = .cameraEffects
            case "audio":
                self = .audioOutput
            case "file":
                self = .fileShare
            case "screenshare":
                self = .screenShare
            case "chat":
                self = .chat
            case "whiteboard":
                self = .whiteboard
            default:
                return nil
        }
    }
}

@available(iOS 15.0, *)
extension Button {

    var callButton: CallButton {
        switch self {
            case .hangUp: .hangUp
            case .microphone: .microphone
            case .camera: .camera
            case .flipCamera: .flipCamera
            case .cameraEffects: .cameraEffects
            case .audioOutput: .audioOutput
            case .fileShare: .fileShare
            case .screenShare: .screenShare
            case .chat: .chat
            case .whiteboard: .whiteboard
        }
    }
}
