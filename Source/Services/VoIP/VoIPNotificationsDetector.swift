// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import PushKit

final class VoIPNotificationsDetector: NSObject, PKPushRegistryDelegate {

    private let registryDelegate: PKPushRegistryDelegate
    private let config: Config.VoIP
    private var appStateObserver: ApplicationStateChangeObservable
    private(set) var pushRegistry: PKPushRegistry?

    var isDetecting: Bool { pushRegistry != nil }

    init(registryDelegate: PKPushRegistryDelegate,
         config: Config.VoIP,
         appStateObserver: ApplicationStateChangeObservable = ApplicationStateChangeObserver()) {
        self.registryDelegate = registryDelegate
        self.config = config
        self.appStateObserver = appStateObserver
    }

    func start() {
        guard !isDetecting else { return }

        pushRegistry = PKPushRegistry(queue: DispatchQueue.init(label: "com.kaleyra.voip_detector_queue"))
        pushRegistry?.delegate = self
        pushRegistry?.desiredPushTypes = [.voIP]
        debugPrint("Started detecting VoIP notifications")
    }

    func stop() {
        guard isDetecting else { return }

        pushRegistry = nil;
        debugPrint("Stopped detecting VoIP notifications")
    }

    override func responds(to aSelector: Selector!) -> Bool {
        guard let aSelector else { return super.responds(to: aSelector) }
        guard aSelector == #selector(PKPushRegistryDelegate.pushRegistry(_:didReceiveIncomingPushWith:for:completion:)) else { return super.responds(to: aSelector) }

        switch config {
            case .manual(strategy: let strategy):
                switch strategy {
                    case .backgroundOnly where appStateObserver.isCurrentAppStateBackground:
                        return true
                    case .always:
                        return true
                    default:
                        return false
                }
            default:
                return false
        }
    }

    // MARK: - Registry delegate

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        registryDelegate.pushRegistry(registry, didUpdate: pushCredentials, for: type)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        registryDelegate.pushRegistry?(registry, didInvalidatePushTokenFor: type)
    }

    dynamic func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        registryDelegate.pushRegistry?(registry, didReceiveIncomingPushWith: payload, for: type, completion: completion)
    }
}
