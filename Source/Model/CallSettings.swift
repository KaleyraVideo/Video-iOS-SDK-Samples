// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

struct CallSettings: Equatable {

    enum PresentationMode: String {
        case fullscreen
        case pip
    }

    enum CameraPosition: String {
        case front
        case back
    }

    struct Tools: Codable, Equatable {
        var isChatEnabled = true
        var isWhiteboardEnabled = true
        var isFileshareEnabled = true
        var isScreenshareEnabled = true
        var isBroadcastEnabled = true

        static let `default`: Tools = .init()
    }

    var type: KaleyraVideoSDK.CallOptions.CallType
    var recording: KaleyraVideoSDK.CallOptions.RecordingType?
    var tools: Tools
    var maximumDuration: UInt
    var isGroup: Bool
    var showsRating: Bool
    var presentationMode: PresentationMode
    var cameraPosition: CameraPosition
    var speakerOverride: ConferenceSettings.SpeakerOverride

    init() {
        type = .audioVideo
        recording = nil
        tools = .default
        maximumDuration = 0
        isGroup = false
        showsRating = false
        presentationMode = .fullscreen
        cameraPosition = .front
        speakerOverride = .default
    }
}

extension CallSettings.PresentationMode: Codable {}

extension CallSettings.PresentationMode: CustomStringConvertible {

    var description: String { rawValue }
}

extension CallSettings.PresentationMode: LosslessStringConvertible {

    init?(_ description: String) {
        switch description.lowercased() {
            case "fullscreen":
                self = .fullscreen
            case "pip":
                self = .pip
            default:
                return nil
        }
    }
}

extension CallSettings.CameraPosition: CaseIterable, Codable {}

extension CallSettings.CameraPosition: CustomStringConvertible {

    var description: String { rawValue }
}

extension CallSettings.CameraPosition: LosslessStringConvertible {

    init?(_ description: String) {
        switch description.lowercased() {
            case "front":
                self = .front
            case "back":
                self = .back
            default:
                return nil
        }
    }
}

extension CallSettings.Tools {

    var asSDKSettings: KaleyraVideoSDK.ConferenceSettings.Tools {
        var config = KaleyraVideoSDK.ConferenceSettings.Tools.default
        config.chat = isChatEnabled ? .enabled : .disabled
        config.broadcastScreenSharing = isBroadcastEnabled ? .enabled(appGroupIdentifier: try! .init("group.com.bandyer.BandyerSDKSample"),
                                                                                  extensionBundleIdentifier: "com.bandyer.BandyerSDKSample.BroadcastExtension") : .disabled
        config.fileshare = isFileshareEnabled ? .enabled : .disabled
        config.inAppScreenSharing = isScreenshareEnabled ? .enabled : .disabled
        config.whiteboard = isWhiteboardEnabled ? .enabled(isUploadEnabled: true) : .disabled
        return config
    }
}

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
    }
}

extension CallSettings {

    private enum DefaultsKeys: String {
        case callSettings = "com.kaleyra.call_settings"
    }

    private enum Errors: Error {
        case objectNotFoundInDefaults
    }

    init(from defaults: UserDefaults) throws {
        guard let object = defaults.object(forKey: DefaultsKeys.callSettings.rawValue) else {
            throw Errors.objectNotFoundInDefaults
        }
        let data = try JSONSerialization.data(withJSONObject: object, options: [.fragmentsAllowed])
        let decoder = JSONDecoder()
        self = try decoder.decode(CallSettings.self, from: data)
    }

    func store(in defaults: UserDefaults) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        defaults.set(object, forKey: DefaultsKeys.callSettings.rawValue)
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

extension Optional where Wrapped == KaleyraVideoSDK.CallOptions.RecordingType {

    var value: Int {
        switch self {
            case .none:
                0
            case .some(let recording):
                recording.value
        }
    }
}

private extension KaleyraVideoSDK.CallOptions.RecordingType {

    var value: Int {
        switch self {
            case .automatic:
                1
            case .manual:
                2
        }
    }

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
