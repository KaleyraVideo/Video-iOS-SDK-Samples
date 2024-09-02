// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import Intents
import KaleyraVideoSDK

protocol Coordinator: AnyObject {

    var parent: Coordinator? { get set }
    var children: [Coordinator] { get }

    @discardableResult
    func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool

    func addChild(_ child: Coordinator)
    func removeChild(_ child: Coordinator)
    func removeAllChildren()
}

enum CoordinatorEvent: Equatable {
    case shakeMotion
    case chatNotification(channelId: String)
    case pushToken(token: String)
    case startCall(url: URL)
    case startOutgoingCall(type: KaleyraVideoSDK.CallOptions.CallType?, callees: [String])
    case openChat(userId: String)
    case siri(intent: INIntent)
    case shareLogFiles
#if SAMPLE_CUSTOMIZABLE_THEME
    case refreshTheme
#endif
}

enum EventDirection {
    case toChildren
    case toParent
}
