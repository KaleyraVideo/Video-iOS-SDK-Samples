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

extension CallSettings {

    private enum Keys: String {
        case type = "com.kaleyra.call_options.type"
        case recording = "com.kaleyra.call_options.recording"
        case tools
        case duration = "com.kaleyra.call_options.duration"
        case group = "com.kaleyra.call_options.group"
        case rating = "com.kaleyra.call_options.rating"
        case presentationMode = "com.kaleyra.call_options.call_presentation_mode"
        case camera
        case speaker
    }

    init?(from defaults: UserDefaults) {
        guard let callTypeRaw = defaults.object(forKey: Keys.type.rawValue) as? UInt,
              let callType = KaleyraVideoSDK.CallOptions.CallType(callTypeRaw),
              let maximumDuration = defaults.object(forKey: Keys.duration.rawValue) as? UInt
        else {
            return nil
        }

        self.init()

        self.type = callType
        self.recording = .init((defaults.object(forKey: Keys.recording.rawValue) as? Int) ?? 0)
        self.maximumDuration = maximumDuration
        self.isGroup = defaults.bool(forKey: Keys.group.rawValue)
        self.showsRating = defaults.bool(forKey: Keys.rating.rawValue)
        self.presentationMode = .init(defaults.string(forKey: Keys.presentationMode.rawValue) ?? "") ?? .fullscreen
        self.cameraPosition = .init(defaults.string(forKey: Keys.camera.rawValue) ?? "") ?? .front
        self.speakerOverride = .init(defaults.string(forKey: Keys.speaker.rawValue) ?? "") ?? .default
    }

    func store(in defaults: UserDefaults) {
        defaults.set(type.value, forKey: Keys.type.rawValue)
        defaults.set(recording.value, forKey: Keys.recording.rawValue)
        defaults.set(maximumDuration, forKey: Keys.duration.rawValue)
        defaults.set(isGroup, forKey: Keys.group.rawValue)
        defaults.set(showsRating, forKey: Keys.rating.rawValue)
        defaults.set(presentationMode.rawValue, forKey: Keys.presentationMode.rawValue)
        defaults.set(cameraPosition.rawValue, forKey: Keys.camera.rawValue)
        defaults.set(speakerOverride.value, forKey: Keys.speaker.rawValue)
    }
}

private extension KaleyraVideoSDK.CallOptions.CallType {

    var value: UInt {
        switch self {
            case .audioVideo:
                0
            case .audioUpgradable:
                1
            case .audioOnly:
                2
        }
    }

    init?(_ value: UInt) {
        switch value {
            case 0:
                self = .audioVideo
            case 1:
                self = .audioUpgradable
            case 2:
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

    init?(_ value: Int) {
        switch value {
            case 0:
                return nil
            case 1:
                self = .automatic
            case 2:
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
