// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

enum Button: Hashable, CaseIterable {
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
    case addCustom
    case custom(Custom)

    static var allCases: [Button] {
        [.hangUp, .microphone, .camera, .flipCamera, .cameraEffects, .audioOutput, .fileShare, .screenShare, .chat, .whiteboard]
    }

    static var `default`: [Button] {
        allCases.filter({
            switch $0 {
                case .addCustom:
                    false
                case .custom:
                    false
                default:
                    true
            }
        })
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Button {

    struct Custom: Hashable {

        let identifier: UUID
        var title: String
        var symbol: String?
        var isEnabled: Bool
        var accessibilityLabel: String?
        var badge: UInt?
        var tint: UIColor?
        var background: UIColor?
        var action: Action?

        var icon: UIImage {
            guard let symbol, let image = UIImage(systemName: symbol) else { return Icons.questionMark }
            return image
        }

        init(identifier: UUID = .init(),
             title: String,
             symbol: String? = nil,
             isEnabled: Bool = true,
             accessibilityLabel: String? = nil,
             badge: UInt? = nil,
             tint: UIColor? = nil,
             background: UIColor? = nil,
             action: Button.Custom.Action? = nil) {
            self.identifier = identifier
            self.title = title
            self.symbol = symbol
            self.isEnabled = isEnabled
            self.accessibilityLabel = accessibilityLabel
            self.badge = badge
            self.tint = tint
            self.background = background
            self.action = action
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier.uuidString)
        }

        static var new: Custom {
            .init(title: "Title", symbol: "questionmark", tint: Theme.Color.defaultButtonTint, background: Theme.Color.defaultButtonBackground)
        }
    }
}

extension Button.Custom {

    enum Action {
        case openMaps
        case openURL
    }
}

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
            case .addCustom: "addCustom"
            case .custom(let custom): custom.identifier.uuidString
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

extension Button: Codable {}

extension Button.Custom: Codable {

    private enum RootKeys: CodingKey {
        case id
        case title
        case icon
        case isEnabled
        case accessibilityLabel
        case badge
        case tint
        case background
        case action
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        self.identifier = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.symbol = try container.decodeIfPresent(String.self, forKey: .icon)
        self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        self.accessibilityLabel = try container.decodeIfPresent(String.self, forKey: .accessibilityLabel)
        self.badge = try container.decodeIfPresent(UInt.self, forKey: .badge)
        self.tint = try container.decodeIfPresent(UInt.self, forKey: .tint).map({ .init(argb: $0) })
        self.background = try container.decodeIfPresent(UInt.self, forKey: .background).map({ .init(argb: $0) })
        self.action = try container.decodeIfPresent(Action.self, forKey: .action)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: RootKeys.self)
        try container.encode(identifier, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(symbol, forKey: .icon)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encodeIfPresent(accessibilityLabel, forKey: .accessibilityLabel)
        try container.encodeIfPresent(badge, forKey: .badge)
        try container.encodeIfPresent(tint?.argb, forKey: .tint)
        try container.encodeIfPresent(background?.argb, forKey: .background)
        try container.encodeIfPresent(action, forKey: .action)
    }
}

extension Button.Custom.Action: Codable {}

@available(iOS 15.0, *)
extension Button {

    var callButton: CallButton? {
        switch self {
            case .hangUp: .hangUp
            case .microphone: .microphone
            case .camera: .camera
            case .flipCamera: .flipCamera
            case .cameraEffects: .cameraEffects
            case .audioOutput: .audioOutput
            case .fileShare: .fileShare
            case .screenShare: .screenShare(onTap: .askUser)
            case .chat: .chat
            case .whiteboard: .whiteboard
            default: nil
        }
    }
}

@available(iOS 15.0, *)
extension Button.Custom {

    var callButton: CallButton.Configuration {
        .init(text: title,
              icon: icon,
              badgeValue: badge,
              isEnabled: isEnabled,
              accessibilityLabel: accessibilityLabel,
              appearance: appearance,
              action: {})
    }

    var appearance: CallButton.Configuration.Appearance? {
        guard let tint, let background else { return nil }
        return .init(background: background, content: tint)
    }
}
