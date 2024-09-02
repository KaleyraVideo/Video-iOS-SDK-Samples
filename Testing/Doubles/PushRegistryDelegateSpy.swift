// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import PushKit

final class PushRegistryDelegateSpy: NSObject, PKPushRegistryDelegate {

    private(set) var pushRegistryInvocations: [(PKPushRegistry, PKPushCredentials)] = []
    private(set) var pushRegistryTokenInvalidationInvocations: [PKPushRegistry] = []
    private(set) var incomingPushPayloads = [PKPushPayload]()

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        pushRegistryInvocations.append((registry, pushCredentials))
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        pushRegistryTokenInvalidationInvocations.append(registry)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        incomingPushPayloads.append(payload)
        completion()
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        incomingPushPayloads.append(payload)
    }
}
