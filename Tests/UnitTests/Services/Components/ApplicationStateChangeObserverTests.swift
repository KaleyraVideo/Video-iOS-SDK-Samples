// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class ApplicationStateChangeObserverTests: UnitTestCase {

    func testSUTInitializationShouldKeepTheNotificationCenterInstancePassed() {
        let center = NotificationCenter()
        let holder = ApplicationStateHolderSpy()
        let sut = ApplicationStateChangeObserver(with: center, holder: holder)

        assertThat(sut.center, sameInstance(center))
    }

    func testNotifiesObserversWhenApplicationBecomesActive() {
        let center = NotificationCenter()
        let holder = ApplicationStateHolderSpy()
        let sut = ApplicationStateChangeObserver(with: center, holder: holder)
        let stateChangeSpy = ApplicationStateChangeObservableSpy()

        sut.listener = stateChangeSpy
        center.post(Notification(name: UIApplication.didBecomeActiveNotification, object: nil, userInfo: nil))

        assertThat(stateChangeSpy.didBecomeActiveCalls, hasCount(1))
    }

    func testNotifiesObserversWhenApplicationEntersBackground() {
        let center = NotificationCenter()
        let holder = ApplicationStateHolderSpy()
        let sut = ApplicationStateChangeObserver(with: center, holder: holder)
        let stateChangeSpy = ApplicationStateChangeObservableSpy()

        sut.listener = stateChangeSpy
        center.post(Notification(name: UIApplication.didEnterBackgroundNotification, object: nil, userInfo: nil))

        assertThat(stateChangeSpy.didEnterBackgroundCalls, hasCount(1))
    }

    func testCallingIsCurrentAppStateBackgroundFromABackgroundThreadShouldAccessApplicationStateFromMainThread() {
        let exp = expectation(description: "The property applicationState should be read from main thread only")
        let center = NotificationCenter()
        let holder = ApplicationStateHolderSpy()
        let sut = ApplicationStateChangeObserver(with: center, holder: holder)

        holder.applicationStateInvocation = {
            assertThat(Thread.isMainThread, isTrue())
            exp.fulfill()
        }

        DispatchQueue.global(qos: .background).async {
            _ = sut.isCurrentAppStateBackground
        }

        wait(for: [exp], timeout: TimeInterval(1))
    }

    func testCallingIsCurrentAppStateBackgroundFromTheMainThreadShouldNotForceExecutionOnMainThread() {
        let exp = expectation(description: "The property applicationState should be read from main thread only")
        let center = NotificationCenter()
        let holder = ApplicationStateHolderSpy()
        let sut = ApplicationStateChangeObserver(with: center, holder: holder)

        holder.applicationStateInvocation = {
            assertThat(Thread.isMainThread, isTrue())
            exp.fulfill()
        }

        DispatchQueue.main.async {
            _ = sut.isCurrentAppStateBackground
        }

        wait(for: [exp], timeout: 1)
    }
}

class ApplicationStateChangeObservableSpy: ApplicationStateChangeListener {

    var didBecomeActiveCalls: [Void] = []
    var didEnterBackgroundCalls: [Void] = []

    func onApplicationDidBecomeActive() {
        didBecomeActiveCalls.append(())
    }

    func onApplicationDidEnterBackground() {
        didEnterBackgroundCalls.append(())
    }
}

class ApplicationStateHolderSpy: ApplicationStateHolder {

    var internalApplicationState: UIApplication.State = .background
    var applicationStateInvocation: (() -> Void)?

    var applicationState: UIApplication.State {
        applicationStateInvocation?()
        return internalApplicationState
    }
}
