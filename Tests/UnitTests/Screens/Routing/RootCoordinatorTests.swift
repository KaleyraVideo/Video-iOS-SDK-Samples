// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class RootCoordinatorTests: UnitTestCase {

    private enum UserDefaultsError: Error {
        case cannotLoadSuite
    }

    private var navigationController: UINavigationController!
    private var testsSuiteName = "testRootCoordinatorTests"

    override func setUp() {
        super.setUp()

        navigationController = .init()
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: testsSuiteName)

        super.tearDown()
    }

    func testStartShouldCreateAndStartALogService() {
        let serviceFactory = makeServicesFactorySpy()
        let sut = makeSUT(servicesFactory: serviceFactory)

        sut.start()

        assertThat(serviceFactory.logServiceSpy.startLoggingInvocations, hasCount(1))
    }

//    func testRootCoordinatorInstantiateControllerForNotLoggedUser() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        sut.start()
//        assertThat(sut.goToLoginCalls.count, equalTo(1))
//
//        let rootVC = try unwrap(navigationController.viewControllers.first)
//        let navController = try unwrap(rootVC.children.first as? UINavigationController)
//        assertThat(navController.viewControllers.first as Any, instanceOf(AppSetupViewController.self))
//    }
//
//    func testRootCoordinatorInstanciateControllerForLoggedUser() throws {
//        let userLoader = UserLoaderStub()
//
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, alias: "arc")
//        sut.start()
//
//        assertThat(sut.goToHomeCalls, equalTo(["arc"]))
//        assertThat(navigationController.viewControllers.first as Any, instanceOf(UITabBarController.self))
//    }
//
//    func testRootCoordinatorShowLoginPageAndAfterLoginLoadMainTabBar() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        sut.start()
//        assertThat(sut.goToLoginCalls.count, equalTo(1))
//
//        let mainVC = try unwrap(navigationController.viewControllers.first)
//        let navController = try unwrap(mainVC.children.first as? UINavigationController)
//        let setupController = try unwrap(navController.viewControllers.first as? AppSetupViewController)
//        setupController.loadViewIfNeeded()
//        assertThat(setupController.tableView.tableFooterView?.firstDescendant() as? RoundedButton, present())
//    }
//
//    func testRootCoordinatorShouldReturnFalseInCanHandleFunctionForAllEventTypesButRefreshThemeEvent() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        sut.start()
//        let shakeMotionEvent = EventCoordinator.shakeMotion
//        let chatNotificationEvent = EventCoordinator.chatNotification
//
//        let canHandleShakeMotionEvent = sut.canHandle(event: shakeMotionEvent)
//        let canHandleChatNotificationEvent = sut.canHandle(event: chatNotificationEvent)
//
//        assertThat(canHandleShakeMotionEvent, isFalse())
//        assertThat(canHandleChatNotificationEvent, isFalse())
//    }
//
//    func testRootCoordinatorShouldForwardEventToChildrenWhenHandleMethodIsCalled() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        let child = CoordinatorSpy()
//        let event = EventCoordinator.chatNotification
//
//        sut.start()
//        sut.addChild(child)
//        try sut.handle(event: event, additionalInfo: nil, eventDirection: .toChildren)
//
//        assertThat(child.handleCalls, hasCount(1))
//    }
//
//    func testRootCoordinatorShouldAddSelfToLoginCoordinatorWhenPushed() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        sut.start()
//
//        sut.goToLogin(isFreshStart: true)
//
//        assertThat(sut.loginCoordinator?.parent, present())
//    }
//
//    func testRootCoordinatorShouldAddSelfToMainCoordinatorWhenPushed() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        sut.start()
//
//        let contact = Contact("test")
//        sut.goToHome(loggedUser: contact)
//
//        assertThat(sut.mainCoordinator?.parent, present())
//    }

#if SAMPLE_CUSTOMIZABLE_THEME

    func testRootCoordinatorShouldRetrurnTrueToCanHandleRefreshThemeEvent() throws {
        let sut = try makeSUT(navigationController: navigationController)

        let canHandle = sut.canHandle(event: .refreshTheme)

        assertThat(canHandle, isTrue())
    }

    func testRootCoordinatorShouldPassTheCurrentAppThemeToItsNavigationControllerWhenReceveARefreshThemeEvent() throws {
        let sut = try makeSUT(navigationController: navigationController)

        navigationController.navigationBar.barStyle = .black
        try sut.handle(event: .refreshTheme, additionalInfo: nil, eventDirection: .toParent)

        assertThat(sut.themeStorage.getSelectedTheme().barStyle, not(equalTo(.black)))
        assertThat(navigationController.navigationBar.barStyle, not(equalTo(.black)))
    }

    func testStartFunctionCallShouldPropagateARefreshThemeEventAfterViewControllersInitialization() throws {
        let sut = try makeSUT(navigationController: navigationController)

        navigationController.navigationBar.barStyle = .black
        sut.start()

        assertThat(sut.themeStorage.getSelectedTheme().barStyle, not(equalTo(.black)))
        assertThat(navigationController.navigationBar.barStyle, not(equalTo(.black)))
    }

    func testLogoutInMainCoordinatorShouldResetSelectedThemeInThemeStorage() throws {
        let sut = try makeSUT(navigationController: navigationController)
        let contact = Contact("test")

        sut.goToHome(loggedUser: contact)
        sut.mainCoordinator?.onLogout?()

        assertThat((sut.themeStorage as? ThemeStorageSpy)?.resetToDefaultValuesInvocations, presentAnd(hasCount(1)))
    }

#endif

    // MARK: - Helpers

    private func makeSUT(servicesFactory: ServicesFactory) -> RootCoordinator {
        .init(services: servicesFactory)
    }

    private func makeServicesFactorySpy() -> ServicesFactorySpy {
        .init()
    }

    // MARK: - Doubles

    private class ServicesFactorySpy: ServicesFactoryStub {

        private(set) var makeLogServiceInvocations: [Void] = []
        let logServiceSpy: LogServiceSpy = .init()

        override func makeLogService() -> LogServiceProtocol {
            makeLogServiceInvocations.append()
            return logServiceSpy
        }
    }

    private class LogServiceSpy: LogServiceProtocol {

        private var _logFileList: [URL] = []
        private(set) var startLoggingInvocations: [Void] = []
        private(set) var stopLoggingInvocations: [Void] = []

        var areLogFilesPresent: Bool {
            !logFileList.isEmpty
        }

        var logFileList: [URL] {
            _logFileList
        }

        func startLogging() {
            startLoggingInvocations.append()
        }

        func stopLogging() {
            stopLoggingInvocations.append()
        }

        func mockLogFileListe(_ list: [URL]) {
            _logFileList = list
        }
    }
}

private extension RootCoordinator {

    var loginCoordinator: LoginCoordinator? {
        children.compactMap({ $0 as? LoginCoordinator }).first
    }

    var mainCoordinator: MainCoordinator? {
        children.compactMap({ $0 as? MainCoordinator }).first
    }
}
