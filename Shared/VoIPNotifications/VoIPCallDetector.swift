//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import PushKit

class VoIPCallDetector: VoIPCallDetectorProtocol, ApplicationStateChangeListener, VoIPPushNotificationHandlerDelegate {

    private let queueIdentifier = "_VoIP_notification_queue_identifier"
    var delegate: VoIPCallDetectorDelegate?
    var detecting: Bool = false

    private let registryDelegate: PKPushRegistryDelegate
    private var appStateObserver: ApplicationStateChangeObservable
    var pushRegistry: PKPushRegistry?

    private var currentRegistryDelegate: PKPushRegistryDelegate? {
        didSet {
            pushRegistry?.delegate = currentRegistryDelegate
        }
    }

    convenience init(registryDelegate: PKPushRegistryDelegate) {
        self.init(registryDelegate: registryDelegate, appStateObserver: ApplicationStateChangeObserver())
    }

    init(registryDelegate: PKPushRegistryDelegate, appStateObserver: ApplicationStateChangeObservable) {
        self.registryDelegate = registryDelegate
        self.appStateObserver = appStateObserver
        self.appStateObserver.listener = self
    }

    func start() {
        guard !detecting else {
            return
        }

        detecting = true
        pushRegistry = PKPushRegistry(queue: DispatchQueue.init(label: queueIdentifier))

        if appStateObserver.isCurrentAppStateBackground {
            attachBackgroundHandler()
        } else {
            attachForegroundHandler()
        }

        pushRegistry?.desiredPushTypes = [.voIP]

        self.delegate?.detectorDidStart?()
    }

    func stop() {
        guard detecting else {
            return
        }

        currentRegistryDelegate = nil;
        pushRegistry = nil;
        detecting = false

        self.delegate?.detectorDidStop?()
    }

    func onApplicationDidBecomeActive() {
        attachForegroundHandler()
    }

    func onApplicationDidEnterBackground() {
        attachBackgroundHandler()
    }

    private func attachForegroundHandler() {
        currentRegistryDelegate = VoIPPushTokenHandler.tokenHandler(withRegistryDelegate: registryDelegate)
    }

    private func attachBackgroundHandler() {
        currentRegistryDelegate = VoIPPushNotificationHandler.handler(withRegistryDelegate: registryDelegate, delegate: self)
    }

    func handle(payload: PKPushPayload) {
        delegate?.handle(payload: payload)
    }
}

protocol VoIPCallDetectorProtocol {

    var delegate: VoIPCallDetectorDelegate? { get }
    var detecting: Bool { get }

    func start()
    func stop()
}

@objc
protocol VoIPCallDetectorDelegate: VoIPPushNotificationHandlerDelegate {
    @objc
    optional func detectorDidStart()
    @objc
    optional func detectorDidStop()
}

