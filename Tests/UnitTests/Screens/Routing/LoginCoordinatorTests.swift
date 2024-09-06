// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class LoginCoordinatorTests: UnitTestCase {

    private enum UserDefaultError: Error {
        case cannotLoadSuite
    }

    private let testsSuiteName = "testRootCoordinatorTests"
//    private let config = QRCode(keys: .any, userAlias: .alice, environment: .development, region: .europe, defaultCallType: nil)
    private var navigationController: UINavigationController!
    private let userLoader = UserRepositoryMock()

    override func setUpWithError() throws {
        try super.setUpWithError()

        navigationController = .init()
    }

    override func tearDownWithError() throws {
        navigationController = nil

        UserDefaults.standard.removePersistentDomain(forName: testsSuiteName)
        try super.tearDownWithError()
    }

//    func testInstanceLoginCoordinatorAndLoadLoginViewControllerOnStart() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//
//        sut.goToLoginPage()
//
//        assertThat(navigationController.loginViewController, presentAnd(instanceOf(LoginViewController.self)))
//        assertThat(sut.goToLoginPageCalls, hasCount(1))
//    }
//
//    func testOpenCallSettingOnTapSettingButtonOnLoginViewController() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//
//        sut.goToLoginPage()
//
//        let loginViewController = try unwrap(navigationController.loginViewController)
//        loginViewController.loadViewIfNeeded()
//
//        let rightBarItemStack: UIStackView? = loginViewController.navigationController?.navigationBar.firstDescendant()
//        assertThat(rightBarItemStack, present())
//
//        let buttons: [UIButton]? = rightBarItemStack?.allDescendants(ofType: UIButton.self) as? [UIButton]
//        let settingButton: UIButton? = buttons?.first(where: { $0.tag == 1 })
//        assertThat(settingButton, present())
//
//        settingButton?.sendActions(for: .touchDown)
//
//        assertThat(sut.openCallSettingCalls, hasCount(1))
//    }
//
//    func testOpenQRReaderOnTapReaderButtonOnSettingViewController() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//
//        sut.goToSetup()
//
//        let setupViewController = try unwrap(navigationController.setupViewController)
//        setupViewController.loadViewIfNeeded()
//
//        let rightBarItemStack: UIStackView? = setupViewController.navigationController?.navigationBar.firstDescendant()
//        assertThat(rightBarItemStack, present())
//
//        let buttons: [UIButton]? = rightBarItemStack?.allDescendants(ofType: UIButton.self) as? [UIButton]
//        let qrCodeButtonButton: UIButton? = buttons?.first(where: { $0.tag == 1 })
//        assertThat(qrCodeButtonButton, present())
//
//        qrCodeButtonButton?.sendActions(for: .touchDown)
//
//        assertThat(sut.goToQRScanCalls, hasCount(1))
//    }

//    func testOpenCallSettingsWhenReceiveNullConfigOnDismissComposeQRReader() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//
//        sut.onQrScanTapped()
//
//        let qrViewController = try unwrap(navigationController.qrReaderViewController)
//
//        qrViewController.onDismiss?(nil)
//
//        assertThat(sut.openCallSettingCalls, hasCount(1))
//        assertThat(sut.goToLoginPageCalls, empty())
//    }
//
//    func testPassCorrectConfigurationWithNoUserAliasOpenTheLoginPage() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//        sut.onQrScanTapped()
//
//        let qrViewController = try unwrap(navigationController.qrReaderViewController)
//        qrViewController.onDismiss?(config)
//
//        assertThat(sut.openCallSettingCalls, empty())
//        assertThat(sut.goToLoginPageCalls, hasCount(1))
//    }
//
//    func testPassCorrectConfigurationWithUserAliasCallTheOnSelectionFunction() throws {
//        let listener = CompletionSpy<Contact>()
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: listener.callAsFunction)
//        sut.onQrScanTapped()
//
//        let qrViewController = try unwrap(navigationController.qrReaderViewController)
//        qrViewController.onDismiss?(config)
//
//        assertThat(sut.openCallSettingCalls, empty())
//        assertThat(sut.goToLoginPageCalls, empty())
//        assertThat(listener.invocations, hasCount(1))
//    }

//    func testCanHandleMethodShouldReturnFalse() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//        let chatEvent = EventCoordinator.chatNotification
//        let shakeEvent = EventCoordinator.shakeMotion
//
//        let canHandleEventChat = sut.canHandle(event: chatEvent)
//        let canHandleEventShake = sut.canHandle(event: shakeEvent)
//
//        assertThat(canHandleEventChat, isFalse())
//        assertThat(canHandleEventShake, isFalse())
//    }
//
//    func testHandleEventShouldForwardEventsToItsChild() throws {
//        let sut = try makeSUT(navigationController: navigationController, userLoader: userLoader, onSelection: { _ in })
//        let child = CoordinatorSpy()
//
//        sut.addChild(child)
//        try sut.handle(event: .chatNotification, additionalInfo: nil, eventDirection: .toChildren)
//
//        assertThat(child.handleCalls, hasCount(1))
//    }

    // MARK: - Helpers

//    private func makeSUT(navigationController: UINavigationController, userLoader: UserLoader, onSelection: @escaping (Contact) -> Void) throws -> LoginCoordinatorSpy {
//        guard let userDefaults = UserDefaults(suiteName: testsSuiteName) else {
//            throw UserDefaultError.cannotLoadSuite
//        }
//
//        return LoginCoordinatorSpy(navigationController: navigationController,
//                                   isFreshStart: true,
//                                   servicesFactory: ServicesFactoryStub(userDefaultsStore: UserDefaultsStore(userDefaults: userDefaults)),
//                                   onSelection: onSelection)
//    }

    // MARK: - Doubles
//
//    private class LoginCoordinatorSpy: LoginCoordinator {
//
//        private(set) var openCallSettingCalls: [Void] = [Void]()
//        private(set) var goToLoginPageCalls: [Void] = [Void]()
//        private(set) var goToQRScanCalls: [Void] = [Void]()
//
//        override func goToSetup() {
//            super.goToSetup()
//            openCallSettingCalls.append(())
//        }
//
//        override func goToLoginPage() {
//            super.goToLoginPage()
//            goToLoginPageCalls.append(())
//        }
//    }
}

private extension UINavigationController {

    var navController: UINavigationController? {
        viewControllers.first as? UINavigationController
    }

    var qrReaderViewController: QRReaderViewController? {
        navController?.viewControllers.first as? QRReaderViewController
    }

    var setupViewController: AppSetupViewController? {
        navController?.viewControllers.first as? AppSetupViewController
    }

    var loginViewController: LoginViewController? {
        navController?.viewControllers.first as? LoginViewController
    }
}
