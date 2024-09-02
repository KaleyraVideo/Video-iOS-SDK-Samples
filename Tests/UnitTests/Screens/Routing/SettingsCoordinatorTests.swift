//// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
//// See LICENSE for licensing information
//
//import Foundation
//import SwiftHamcrest
//import KaleyraTestKit
//@testable import SDK_Sample
//
//final class SettingsCoordinatorTests: UnitTestCase {
//
//#if SAMPLE_CUSTOMIZABLE_THEME
//    func testOpenThemeShouldPushAThemeViewControllerInTheNavigationStack() {
//        let sut = makeSUT()
//
//        sut.openTheme()
//
//        assertThat(sut.navigationController.viewControllers, hasCount(1))
//        assertThat(sut.navigationController.viewControllers.last as? ThemeViewController, present())
//        assertThat((sut.navigationController.viewControllers.last as? ThemeViewController)?.viewModel, present())
//    }
//
//    func testOpenThemeShouldAddChildrenToCoordinator() {
//        let sut = makeSUT()
//
//        sut.openTheme()
//
//        assertThat(sut.getChildren(), hasCount(1))
//    }
//
//    func testThemeCoordinatorShouldBeInitializedWithPickerFactory() {
//        let sut = makeSUT()
//
//        sut.openTheme()
//
//        let themeCoordinator = sut.getChildren().last as? ThemeCoordinator
//
//        assertThat(themeCoordinator?.pickerFactory, present())
//    }
//#endif
//
//    func testOnLogoutMethodShouldCallSettingsCoordinatorDelegateMethod() {
//        let sut = makeSUT()
//        let delegate = makeDelegateSpy()
//        sut.delegate = delegate
//
//        sut.onLogout()
//
//        assertThat(delegate.logoutInvocations, hasCount(1))
//    }
//
//    func testOnContaMethodShouldCallSettingsCoordinatorDelegateMethod() {
//        let sut = makeSUT()
//        let delegate = makeDelegateSpy()
//        sut.delegate = delegate
//
//        let contact = Contact(.foo)
//        sut.onUpdateUser(contact: contact)
//
//        assertThat(delegate.updateContactInvocations.first?.alias, presentAnd(equalTo(.foo)))
//    }
//
//    func testCreatesNavigationControllerWithSettingViewControllerAsRoot() {
//        let sut = makeSUT()
//
//        assertThat(sut.navigationController.viewControllers.first, presentAnd(instanceOf(SettingsViewController.self)))
//    }
//
//    func testComposeSettingsShouldSetTheFlowDelegateToTheSettingViewController() {
//        let sut = makeSUT()
//
//        let settingsVc = sut.navigationController.viewControllers.first as? SettingsViewController
//
//        assertThat(settingsVc?.delegate as? SettingsCoordinator, presentAnd(sameInstance(sut)))
//    }
//
//    // MARK: - Helpers
//
//    private func makeSUT(userId: String = .alice, config: Config = .init(keys: .any)) -> SettingsCoordinator {
//        .init(servicesFactory: ServicesFactoryStub(), loggedUser: ContactsGenerator(seed: UInt64(100)).contact(userId), config: config)
//    }
//
//    private func makeDelegateSpy() -> DelegateSpy {
//        .init()
//    }
//
//    // MARK: - Doubles
//
//    private class DelegateSpy: SettingsCoordinatorDelegate {
//
//        private(set) lazy var logoutInvocations: [Void] = []
//        private(set) lazy var resetInvocations: [Void] = []
//        private(set) lazy var updateContactInvocations = [Contact]()
//
//        func settingsCoordinatorDidLogout() {
//            logoutInvocations.append()
//        }
//
//        func settingsCoordinatorDidReset() {
//            resetInvocations.append()
//        }
//
//        func settingsCoordinatorDidUpdateContact(contact: SDK_Sample.Contact) {
//            updateContactInvocations.append(contact)
//        }
//
//    }
//}
