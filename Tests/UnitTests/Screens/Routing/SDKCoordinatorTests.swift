//// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
//// See LICENSE for licensing information
//
//import XCTest
//import UIKit
//import SwiftHamcrest
//import KaleyraTestKit
//import Foundation
//import KaleyraVideoSDK
//@testable import SDK_Sample
//
//final class BandyerCoordinatorTests: UnitTestCase {
//
//    func testSUTShouldReturnTrueInCanHandleEventPassingShakeMotionEventOrChatNotificationEvent() {
//        let sut = makeSUT()
//        let shakeMotionEvent = EventCoordinator.shakeMotion
//        let chatNotificationEvent = EventCoordinator.chatNotification
//
//        let canHandleShakeMotionEvent = sut.canHandle(event: shakeMotionEvent)
//        let canHandleChatNotificationEvent = sut.canHandle(event: chatNotificationEvent)
//
//        assertThat(canHandleShakeMotionEvent, isTrue())
//        assertThat(canHandleChatNotificationEvent, isTrue())
//    }
//
//#if SAMPLE_CUSTOMIZABLE_THEME
//
//    func testShouldForwardEvenToChildrenIfNotCanHandleAndEventDirectionIsToChildren() throws {
//        let tokenLoader = TokenLoaderSpy()
//        let config = Config(keys: .any, showUserInfo: true)
//        let sut = BandyerCoordinatorSpy(callOptionsItem: CallOptions(), config: config, navigationController: UINavigationController(), deviceToken: nil, tokenLoader: tokenLoader, themeStorage: ThemeStorageSpy())
//        let child = ChainCoordinatorSpy()
//
//        sut.addChild(child)
//        try sut.handle(event: .refreshTheme, additionalInfo: nil, eventDirection: .toChildren)
//
//        assertThat(child.handleCalls, hasCount(1))
//    }
//
//    func testShoulForwardEvenToParentIfNotCanHandleAndEventDirectionIsToParent() throws {
//        let tokenLoader = TokenLoaderSpy()
//        let config = Config(keys: .any, showUserInfo: true)
//        let sut = BandyerCoordinatorSpy(callOptionsItem: CallOptions(), config: config, navigationController: UINavigationController(), deviceToken: nil, tokenLoader: tokenLoader, themeStorage: ThemeStorageSpy())
//        let parent = ChainCoordinatorSpy()
//
//        sut.parent = parent
//        try sut.handle(event: .refreshTheme, additionalInfo: nil, eventDirection: .toParent)
//
//        assertThat(parent.handleCalls, hasCount(1))
//    }
//
//#endif
//
//    func testSUTInitializedWithConfigKeyManuallyHandleVoIPNotificationShouldInstantiateCallDetectorProperty() {
//        let config = Config(keys: .any, showUserInfo: true, voip: .manual(strategy: .always))
//        let sut = makeSUT(config: config)
//
//        assertThat(sut.callDetector, present())
//        assertThat(sut.callDetector?.delegate, presentAnd(isA(BandyerCoordinator.self)))
//        assertThat(sut.callDetector?.delegate as? BandyerCoordinator, presentAnd(sameInstance(sut)))
//    }
//
//    func testStartShouldStartCallCallDetector() {
//        let config = Config(keys: .any, showUserInfo: true, voip: .manual(strategy: .always))
//        let sut = makeSUT(config: config)
//
//        sut.start(userId: "alias")
//
//        assertThat(sut.isStarted, isTrue())
//        assertThat(sut.callDetector?.detecting, presentAnd(isTrue()))
//    }
//
//    func testStopShouldStopCallDetector() {
//        let config = Config(keys: .any, showUserInfo: true, voip: .manual(strategy: .always))
//        let sut = makeSUT(config: config)
//
//        sut.start(userId: "alias")
//        sut.stop()
//
//        assertThat(sut.isStarted, isFalse())
//        assertThat(sut.callDetector?.detecting, presentAnd(isFalse()))
//    }
//
//#if SAMPLE_CUSTOMIZABLE_THEME
//    func testChatControllerShouldBePresentedWithTheSelectedThemeInstance() {
//        let tokenLoader = TokenLoaderSpy()
//        let config = Config(keys: .any, showUserInfo: true)
//        let themeStorageSpy = ThemeStorageSpy()
//        let sut = BandyerCoordinator(callOptionsItem: CallOptions(), config: config, navigationController: UINavigationController(), deviceToken: nil, tokenLoader: tokenLoader, themeStorage: themeStorageSpy)
//
//        sut.start(userId: "prova")
//        sut.handleClientChatAction(aliasId: "test")
//
//        assertThat(themeStorageSpy.getSelectedThemeInvocations, hasCount(1))
//    }
//#endif
//
//    // MARK: - Helper
//
//    private func makeSUT(config: SDK_Sample.Config = Config(keys: .any, showUserInfo: true),
//                         tokenLoader: TokenLoader & AccessTokenProvider = TokenLoaderSpy()) -> BandyerCoordinator {
//        BandyerCoordinator(navigationController: UINavigationController(),
//                           config: config,
//                           callOptions: CallOptions(),
//                           pushToken: nil,
//                           servicesFactory: ServicesFactoryStub(tokenLoader: tokenLoader))
//    }
//
//    // MARK: - Doubles
//
//    private class BandyerCoordinatorSpy: BandyerCoordinator {
//
//        private(set) var handleClientChatActionCalls: [String] = []
//
//        override func handleClientChatAction(aliasId: String) {
//            handleClientChatActionCalls.append(aliasId)
//        }
//    }
//
//    private class BandyerCoordinatorDelegateSpy: BandyerCoordinatorDelegate {
//
//        private(set) var didFinishWithErrorInvocations: [Error] = []
//
//        func didFinish(withError: Error) {
//            didFinishWithErrorInvocations.append(withError)
//        }
//
//        func isLoading(_ isLoading: Bool) { }
//    }
//}
