// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import PushKit
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
import KaleyraTestHelpers
@testable import SDK_Sample

final class VoIPNotificationsDetectorTests: UnitTestCase, ConditionalTestCase, CompletionSpyFactory {

    private var delegate: PushRegistryDelegateSpy!
    private var applicationState: ApplicationStateMock!
    private var payload: PKPushPayload!

    override func setUp() {
        super.setUp()

        delegate = .init()
        applicationState = .init()
        payload = .init()
    }

    override func tearDown() {
        payload = nil
        applicationState = nil
        delegate = nil

        super.tearDown()
    }

    func testStartInstantiatePushRegistry() {
        let sut = makeSUT()

        sut.start()

        assertThat(sut.isDetecting, isTrue())
        assertThat(sut.pushRegistry, present())
        assertThat(sut.pushRegistry!.delegate, present())
        assertThat(sut.pushRegistry!.desiredPushTypes, equalTo([.voIP]))
    }

    func testStopRemovesRegistry() {
        let sut = makeSUT()

        sut.start()
        sut.stop()

        assertThat(sut.isDetecting, isFalse())
        assertThat(sut.pushRegistry, nilValue())
    }

    func testRespondsToDidReceiveIncomingPushWhenAppGoesInBackground() {
        let sut = makeSUT()

        sut.start()
        applicationState.isCurrentAppStateBackground = true

        assertThat((sut as PKPushRegistryDelegate).responds(to: #selector(PKPushRegistryDelegate.pushRegistry(_:didReceiveIncomingPushWith:for:completion:))), isTrue())
    }

    func testDoesNotRespondToDidReceiveIncomingPushWhenAppGoesInForeground() {
        let sut = makeSUT()

        sut.start()
        applicationState.isCurrentAppStateBackground = false

        assertThat((sut as PKPushRegistryDelegate).responds(to: #selector(PKPushRegistryDelegate.pushRegistry(_:didReceiveIncomingPushWith:for:completion:))), isFalse())
    }

    func testRespondsToDidReceiveIncomingPushWhenConfiguredForListeningForNotificationsInForeground() {
        let sut = makeSUT(config: .manual(strategy: .always))

        sut.start()
        applicationState.isCurrentAppStateBackground = false

        assertThat((sut as PKPushRegistryDelegate).responds(to: #selector(PKPushRegistryDelegate.pushRegistry(_:didReceiveIncomingPushWith:for:completion:))), isTrue())
    }

    func testDidReceiveIncomingPushShouldForwardPayloadToDelegate() {
        let sut = makeSUT(config: .automatic(strategy: .always))
        sut.start()

        sut.pushRegistry(sut.pushRegistry!, didReceiveIncomingPushWith: payload, for: .voIP, completion: {})

        assertThat(delegate.incomingPushPayloads, hasCount(1))
        assertThat(delegate.incomingPushPayloads.first, equalTo(payload))
    }

    func testDidReceiveIncomingPushShouldInvokeCompletionBlock() {
        let sut = makeSUT(config: .automatic(strategy: .always))
        sut.start()

        let completionSpy = makeVoidCompletionSpy()
        sut.pushRegistry(sut.pushRegistry!, didReceiveIncomingPushWith: payload, for: .voIP, completion: completionSpy.callAsFunction)

        assertThat(completionSpy.invocations, hasCount(1))
    }

    func testNotifiesDelegateWhenPushCredentialsAreUpdated() {
        let sut = makeSUT()

        sut.start()
        let credentials = PKPushCredentials()
        sut.pushRegistry(sut.pushRegistry!, didUpdate: credentials, for: .voIP)

        assertThat(delegate.pushRegistryInvocations, hasCount(1))
        assertThat(delegate.pushRegistryInvocations.first?.0, equalTo(sut.pushRegistry!))
        assertThat(delegate.pushRegistryInvocations.first?.1, equalTo(credentials))
    }

    func testNotifiesDelegateWhenPushCredentialsAreInvalidated() {
        let sut = makeSUT()

        sut.start()
        sut.pushRegistry(sut.pushRegistry!, didInvalidatePushTokenFor: .voIP)

        assertThat(delegate.pushRegistryTokenInvalidationInvocations, hasCount(1))
        assertThat(delegate.pushRegistryTokenInvalidationInvocations.first, equalTo(sut.pushRegistry!))
    }

    // MARK: - Helpers

    private func makeSUT(config: Config.VoIP = .manual(strategy: .backgroundOnly)) -> VoIPNotificationsDetector {
        return .init(registryDelegate: delegate, config: config, appStateObserver: applicationState)
    }

    // MARK: - Doubles

    private class ApplicationStateMock: ApplicationStateChangeObservable {

        var isCurrentAppStateBackground: Bool = false
        var listener: ApplicationStateChangeListener?
    }
}
