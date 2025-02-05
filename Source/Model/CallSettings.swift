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
    var enableCustomButtons: Bool
    var buttons: [Button]

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
        enableCustomButtons = false
        buttons = Button.default
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
