// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

struct CallOptions {

    enum PresentationMode: Int {
        case fullscreen = 0
        case pip = 1
    }

    var type: KaleyraVideoSDK.CallOptions.CallType
    var recording: KaleyraVideoSDK.CallOptions.RecordingType?
    var maximumDuration: UInt
    var isGroup: Bool
    var showsRating: Bool
    var presentationMode: PresentationMode

    init() {
        type = .audioVideo
        recording = nil
        maximumDuration = 0
        isGroup = false
        showsRating = false
        presentationMode = .fullscreen
    }
}

extension CallOptions {

    private enum Keys: String {
        case type = "com.kaleyra.call_options.type"
        case recording = "com.kaleyra.call_options.recording"
        case duration = "com.kaleyra.call_options.duration"
        case group = "com.kaleyra.call_options.group"
        case rating = "com.kaleyra.call_options.rating"
        case presentationMode = "com.kaleyra.call_options.call_presentation_mode"
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
        self.presentationMode = .init(rawValue: defaults.integer(forKey: Keys.presentationMode.rawValue)) ?? .fullscreen
    }

    func store(in defaults: UserDefaults) {
        defaults.set(type.value, forKey: Keys.type.rawValue)
        defaults.set(recording.value, forKey: Keys.recording.rawValue)
        defaults.set(maximumDuration, forKey: Keys.duration.rawValue)
        defaults.set(isGroup, forKey: Keys.group.rawValue)
        defaults.set(showsRating, forKey: Keys.rating.rawValue)
        defaults.set(presentationMode.rawValue, forKey: Keys.presentationMode.rawValue)
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
