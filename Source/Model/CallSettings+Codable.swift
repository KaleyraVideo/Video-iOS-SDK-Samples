// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

extension CallSettings: Codable {

    private enum Keys: String, CodingKey {
        case type
        case recording
        case tools
        case duration
        case group
        case rating
        case presentationMode
        case camera
        case speaker
        case enableCustomButtons
        case customButtons
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.type = .init(try container.decodeIfPresent(String.self, forKey: .type) ?? "") ?? .audioVideo
        self.recording = .init(try container.decodeIfPresent(String.self, forKey: .recording) ?? "") ?? nil
        self.tools = try container.decodeIfPresent(CallSettings.Tools.self, forKey: .tools) ?? .default
        self.maximumDuration = try container.decodeIfPresent(UInt.self, forKey: .duration) ?? 0
        self.isGroup = try container.decodeIfPresent(Bool.self, forKey: .group) ?? false
        self.showsRating = try container.decodeIfPresent(Bool.self, forKey: .rating) ?? false
        self.presentationMode = .init(try container.decodeIfPresent(String.self, forKey: .presentationMode) ?? "") ?? .fullscreen
        self.cameraPosition = .init(try container.decodeIfPresent(String.self, forKey: .camera) ?? "") ?? .front
        self.speakerOverride = .init(try container.decodeIfPresent(String.self, forKey: .speaker) ?? "") ?? .default
        self.enableCustomButtons = try container.decodeIfPresent(Bool.self, forKey: .enableCustomButtons) ?? false
        self.buttons = (try? .init(from: decoder)) ?? []
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(type.description, forKey: .type)
        try container.encodeIfPresent(recording?.description, forKey: .recording)
        try container.encode(tools, forKey: .tools)
        try container.encode(maximumDuration, forKey: .duration)
        try container.encode(isGroup, forKey: .group)
        try container.encode(showsRating, forKey: .rating)
        try container.encode(presentationMode, forKey: .presentationMode)
        try container.encode(cameraPosition, forKey: .camera)
        try container.encode(speakerOverride.value, forKey: .speaker)
        try container.encode(enableCustomButtons, forKey: .enableCustomButtons)
        try container.encode(buttons, forKey: .customButtons)
    }
}

private extension KaleyraVideoSDK.CallOptions.CallType {

    init?(_ string: String) {
        switch string.lowercased() {
            case "audio video":
                self = .audioVideo
            case "audio upgradable":
                self = .audioUpgradable
            case "audio only":
                self = .audioOnly
            default:
                return nil
        }
    }
}

private extension KaleyraVideoSDK.CallOptions.RecordingType {

    init?(_ value: String) {
        switch value.lowercased() {
            case "":
                return nil
            case "automatic":
                self = .automatic
            case "manual":
                self = .manual
            default:
                return nil
        }
    }
}

private extension ConferenceSettings.SpeakerOverride {

    var value: String {
        switch self {
            case .never:
                "never"
            case .always:
                "always"
            case .video:
                "video"
            case .videoForeground:
                "videoForeground"
        }
    }

    init?(_ rawValue: String) {
        switch rawValue {
            case "never":
                self = .never
            case "always":
                self = .always
            case "video":
                self = .video
            case "videoForeground":
                self = .videoForeground
            default:
                return nil
        }
    }
}
