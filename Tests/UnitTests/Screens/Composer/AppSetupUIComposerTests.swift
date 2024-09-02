//// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
//// See LICENSE.txt for licensing information
//
//import XCTest
//import SwiftHamcrest
//import KaleyraTestKit
//@testable import SDK_Sample
//
//final class AppSetupUIComposerTests: UnitTestCase {
//
//    private var sut: AppSetupCoordinator!
//    let config = Config(keys: .any, showUserInfo: true, environment: .sandbox)
//
//    override func setUpWithError() throws {
//        try super.setUpWithError()
//
//        sut = .init(servicesFactory: ServicesFactoryStub(), onQrScanTapped: {})
//    }
//
//    override func tearDownWithError() throws {
//        sut = nil
//
//        try super.tearDownWithError()
//    }
//
//    func testCreatesNavigationControllerWithCallOptionsTableViewControllerAsRoot() throws {
//        let vc = compose()
//
//        let navController = try unwrap(vc as? UINavigationController)
//        assertThat(navController.viewControllers.first as Any, instanceOf(AppSetupViewController.self))
//    }
//
//    func testNavigationBarItemsAndQRCodeAction() throws {
//        let vc = compose()
//
//        let (navController, _) = try assertViewControllerHierarchy(viewController: vc)
//        assertThat(navController.navigationBar.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
//
//        let mainStack: UIStackView = try unwrap(navController.navigationBar.firstDescendant())
//        let qrCodeButton: UIButton = try unwrap(mainStack.firstDescendant())
//        assertThat(qrCodeButton.allTargets.count, equalTo(1))
//        assertThat(qrCodeButton.tag, equalTo(1))
//        assertThat(qrCodeButton.contentMode, equalTo(.scaleAspectFit))
//        assertThat(qrCodeButton.image(for: .normal), equalTo(UIImage(named: "qrcode")))
//        assertThat(mainStack.translatesAutoresizingMaskIntoConstraints, isFalse())
//        assertThat(qrCodeButton.translatesAutoresizingMaskIntoConstraints, isFalse())
//    }
//
//    func testCallFunctionPassedToComposerWhenTapQrCodeButtonInNavigation() throws {
//        let listener = CompletionSpy<Void>()
//        let sut = AppSetupCoordinator(servicesFactory: ServicesFactoryStub(), onQrScanTapped: listener.callAsFunction)
//        let vc = sut.makeViewController(config: config, onDismiss: { _ in })
//
//        let (navController, _) = try assertViewControllerHierarchy(viewController: vc)
//        assertThat(navController.navigationBar.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
//
//        let mainStack: UIStackView = try unwrap(navController.navigationBar.firstDescendant())
//        let qrCodeButton: UIButton = try unwrap(mainStack.firstDescendant())
//        qrCodeButton.sendActions(for: .touchDown)
//        assertThat(listener.invocations, hasCount(1))
//    }
//
//    func testComposeSetsNavigationItemPrefersLargeTitleToTrue() throws {
//        let vc = compose()
//
//        let (navController, _) = try assertViewControllerHierarchy(viewController: vc)
//        assertThat(navController.navigationBar.prefersLargeTitles, isTrue())
//    }
//
//    // MARK: - Helpers
//
//    private func compose() -> UIViewController {
//        sut.makeViewController(config: Config(keys: .any, showUserInfo: true, environment: .sandbox), onDismiss: { _ in })
//    }
//
//    private func assertViewControllerHierarchy(viewController: UIViewController, file: StaticString = #filePath, line: UInt = #line ) throws -> (UINavigationController, AppSetupViewController) {
//        let navController = try XCTUnwrap(viewController as? UINavigationController, file: file, line: line)
//        let environmentOptionsController = try XCTUnwrap(navController.viewControllers.first as? AppSetupViewController, file: file, line: line)
//        return (navController, environmentOptionsController)
//    }
//}
