// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

class ApplicationStateChangeObserver: ApplicationStateChangeObservable {

    let center: NotificationCenter
    let stateHolder: ApplicationStateHolder
    var listener: ApplicationStateChangeListener?

    convenience init() {
        self.init(with: NotificationCenter.default, holder: UIApplication.shared)
    }

    init(with center: NotificationCenter, holder: ApplicationStateHolder) {
        self.center = center
        self.stateHolder = holder

        addObservers()
    }

    private func addObservers() {
        center.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc
    private func applicationDidBecomeActive(_ notification: Foundation.Notification) {
        listener?.onApplicationDidBecomeActive()
    }

    @objc
    private func applicationDidEnterBackground(_ notification: Foundation.Notification) {
        listener?.onApplicationDidEnterBackground()
    }

    var isCurrentAppStateBackground: Bool {
        var background = false

        let accessPropertyFunction = { [weak self] in
            guard let self = self else { return }
            background = self.stateHolder.applicationState == .background
        }

        if Thread.isMainThread {
            accessPropertyFunction()
        } else {
            DispatchQueue.main.sync(execute: accessPropertyFunction)
        }

        return background
    }
}

protocol ApplicationStateChangeListener {
    func onApplicationDidBecomeActive()
    func onApplicationDidEnterBackground()
}

protocol ApplicationStateChangeObservable {
    var listener: ApplicationStateChangeListener? { get set }
    var isCurrentAppStateBackground: Bool { get }
}

protocol ApplicationStateHolder {
    var applicationState: UIApplication.State { get }
}

extension UIApplication: ApplicationStateHolder { }
