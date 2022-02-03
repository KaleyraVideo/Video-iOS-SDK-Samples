// Copyright © 2018-2022 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import PushKit

class VoIPPushTokenHandler: NSObject, PKPushRegistryDelegate {

    var registryDelegate: PKPushRegistryDelegate

    fileprivate init(with registryDelegate: PKPushRegistryDelegate) {
        self.registryDelegate = registryDelegate
    }

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        registryDelegate.pushRegistry(registry, didUpdate: pushCredentials, for: type)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        registryDelegate.pushRegistry?(registry, didInvalidatePushTokenFor: type)
    }

    static func tokenHandler(withRegistryDelegate delegate: PKPushRegistryDelegate) -> VoIPPushTokenHandler {
        if #available(iOS 11, *) {
            return VoIPPushTokenHandler(with: delegate)
        } else {
            return LegacyVoIPPushTokenHandler(with: delegate)
        }
    }
}

class LegacyVoIPPushTokenHandler: VoIPPushTokenHandler {

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        // Even tough this method is marked as optional if a VoIP push notification is received on iOS 10 the registry will call this method anyway
        // To workaround this issue we implement this method with an empty implementation
        return
    }
}

class VoIPPushNotificationHandler: VoIPPushTokenHandler {

    let delegate:VoIPPushNotificationHandlerDelegate

    fileprivate init(with registryDelegate: PKPushRegistryDelegate, delegate: VoIPPushNotificationHandlerDelegate) {
        self.delegate = delegate
        super.init(with: registryDelegate)
    }

    func handleNotification(payload: PKPushPayload) {
        delegate.handle(payload: payload)
    }

    static func handler(withRegistryDelegate registryDelegate: PKPushRegistryDelegate, delegate: VoIPPushNotificationHandlerDelegate) -> VoIPPushNotificationHandler {
        if #available(iOS 13, *) {
            return ModernVoIPPushNotificationHandler(with: registryDelegate, delegate: delegate)
        } else {
            return LegacyVoIPPushNotificationHandler(with: registryDelegate, delegate: delegate)
        }
    }
}

@objc
protocol VoIPPushNotificationHandlerDelegate {
    func handle(payload: PKPushPayload)
}

@available(iOS 13, *)
class ModernVoIPPushNotificationHandler: VoIPPushNotificationHandler {
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        delegate.handle(payload: payload)
        completion()
    }
}

class LegacyVoIPPushNotificationHandler: VoIPPushNotificationHandler {
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        delegate.handle(payload: payload)
    }
}
