//// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
//// See LICENSE.txt for licensing information
//
//import XCTest
//import KaleyraTestKit
//@testable import SDK_Sample
//import SwiftHamcrest
//
//final class MainCoordinatorTests: UnitTestCase {
//
//    enum UserDefaultError: Error {
//        case cannotLoadSuite
//    }
//
//    private let testsSuiteName = "MainCoordinatorTests"
//    private let contactsGenerator = ContactsGenerator(seed: UInt64(100))
//
//    private var navigationController: UINavigationController!
//
//    override func setUpWithError() throws {
//        try super.setUpWithError()
//
//        navigationController = .init()
//    }
//
//    override func tearDownWithError() throws {
//        UserDefaults.standard.removePersistentDomain(forName: testsSuiteName)
//
//        try super.tearDownWithError()
//    }
//
//    func testMainCoordinatorInstanciateMainUIFactory() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        let rootVC = try unwrap(sut.navigationController.viewControllers.first)
//
//        assertThat(rootVC as Any, instanceOf(UITabBarController.self))
//        let contactsNavController = try unwrap(rootVC.children.first as? UINavigationController)
//        assertThat(contactsNavController.viewControllers.first as Any, instanceOf(ContactsViewController.self))
//        let settingsNavController = try unwrap(rootVC.children.last as? UINavigationController)
//        assertThat(settingsNavController.viewControllers.first as Any, instanceOf(SettingsViewController.self))
//        assertThat(sut.goToMainPageCalls.count, equalTo(1))
//    }
//
//    func testOpenUpdateContactOnCallUpdateFunctionOfControllerOnContactsViewController() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        let rootVC = try unwrap(sut.navigationController.viewControllers.first)
//        let contactsNavController = try unwrap(rootVC.children.first as? UINavigationController)
//        let contactsViewController = try unwrap(contactsNavController.viewControllers.first as? ContactsViewController)
//        contactsViewController.loadViewIfNeeded()
//
//        contactsViewController.onUpdateContact?(Contact(.alice))
//
//        assertThat(contactsViewController.modalPresentationStyle, equalTo(.pageSheet))
//        assertThat(sut.onUpdateContactCalls.count, equalTo(1))
//        assertThat(sut.onUpdateContactCalls.first?.alias, equalTo(.alice))
//    }
//
//    func testCanHandleFunctionShouldReturnFalseWhenCalled() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        let eventChat = EventCoordinator.chatNotification
//        let eventShake = EventCoordinator.shakeMotion
//
//        let eventTestedChat = sut.canHandle(event: eventChat)
//        let eventTestedShake = sut.canHandle(event: eventShake)
//
//        assertThat(eventTestedChat, isFalse())
//        assertThat(eventTestedShake, isFalse())
//    }
//
//    func testMainCoordinatorShouldForwardHandleFunctionCallToItsChild() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        let child = CoordinatorSpy()
//
//        sut.addChild(child)
//        try sut.handle(event: .shakeMotion, additionalInfo: nil, eventDirection: .toChildren)
//
//        assertThat(child.handleCalls, hasCount(1))
//    }
//
//    func testMainCoordinatorInitializationShouldProperlyCreateItsChildColordinators() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        assertThat(sut.getChildren(), hasCount(2))
//        assertThat(sut.getChildren().first, presentAnd(instanceOf(BandyerCoordinator.self)))
//        assertThat(sut.getChildren().last, presentAnd(instanceOf(SettingsCoordinator.self)))
//    }
//
//    func testSettingsCoordinatorInstantiationShouldPassANewInstanceOfUINavigationController() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        assertThat(sut.settingsCoordinator?.navigationController, presentAnd(not(sameInstance(navigationController))))
//    }
//
//    func testSettingsCoordinatorShouldHaveTheNavigationControllerProperlyConfigured() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        assertThat(sut.settingsCoordinator?.navigationController.navigationBar.prefersLargeTitles, presentAnd(isTrue()))
//    }
//
//    func testSUTShouldBePassedAsSettingsCoordinatorDelegateOnInitialization() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        assertThat(sut.settingsCoordinator?.delegate as? MainCoordinator, presentAnd(sameInstance(sut)))
//    }
//
//    func testSUTInvokesOnLogoutClosureWhenLogoutFunctionIsInvoked() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//        let logoutListener = CompletionSpy<Void>()
//
//        sut.onLogout = logoutListener.callAsFunction
//        sut.logout()
//
//        assertThat(logoutListener.invocations, hasCount(1))
//    }
//
//    func testLogoutShouldStopBandyerCoordinator() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice)
//
//        sut.bandyerCoordinator.start(userId: .alice)
//        sut.logout()
//
//        assertThat(sut.bandyerCoordinator.isStarted, isFalse())
//    }
//
//    func testSUTInvokesOnUpdateContactWhenupdateContactFunctionIsInvoked() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice)
//
//        sut.updateContact(contact: Contact(.bob))
//
//        assertThat(sut.onUpdateContactCalls, hasCount(1))
//        assertThat(sut.onUpdateContactCalls.first?.alias, presentAnd(equalTo(.bob)))
//    }
//
//    func testMainCoordinatorShouldAddSelfToParentOfBandyerAndSettingsCoordinators() throws {
//        let sut = try makeSUT(navigationController: navigationController)
//
//        assertThat(sut.bandyerCoordinator.parent, present())
//        assertThat(sut.settingsCoordinator?.parent, present())
//    }
//
//    func testNumberOfTabsInsideTabBarController() throws {
//        let tabBarController = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//
//        let vcs = try unwrap(tabBarController.viewControllers)
//        assertThat(vcs.count, equalTo(2))
//    }
//
//    func testShowContactViewControllerAsFirstController() throws {
//        let sut = try checkAndGetViewController(at: 0)
//
//        assertThat(sut, present())
//
//        let vc = try unwrap(sut as? ContactsViewController)
//
//        assertThat(vc.tabBarItem.title, equalTo(Strings.Contacts.tabName))
//    }
//
//    func testShowSettingViewControllerAsLastController() throws {
//        let sut = try checkAndGetViewController(at: 1)
//
//        assertThat(sut, present())
//
//        let vc = try unwrap(sut as? SettingsViewController)
//
//        assertThat(vc.tabBarItem.title, equalTo(Strings.Settings.tabName))
//    }
//
//    func testDoNotExixtsNavigationController() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//
//        assertThat(sut.navigationController, nilValue())
//    }
//
//    func testMainTabBarControllerTintColor() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//
//        assertThat(sut.tabBar.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
//    }
//
//    func testTabBarIsTranslucent() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//
//        assertThat(sut.tabBar.isTranslucent, equalTo(false))
//    }
//
//    func testMainTabBarControllerBarTintColor() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//
//        assertThat(sut.tabBar.barTintColor?.cgColor, equalTo(Theme.Color.commonWhiteColor.cgColor))
//    }
//
//    func testMainTabBarControllerUnselectedTintColor() throws {
//        let sut = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//
//        assertThat(sut.tabBar.unselectedItemTintColor, equalTo(Theme.Color.unselectedTintTabBar))
//    }
//
//    // MARK: - Helpers
//
//    private func makeSUT(navigationController: UINavigationController,
//                         alias: String = .alice) throws -> MainCoordinatorSpy {
//        guard let userDefaults = UserDefaults(suiteName: testsSuiteName) else {
//            throw UserDefaultError.cannotLoadSuite
//        }
//
//        let loggedUser = contactsGenerator.contact(alias)
//        let store = UserDefaultsStore(userDefaults: userDefaults)
//        store.setLoggedUser(userAlias: alias)
//        let sut = MainCoordinatorSpy(navigationController: navigationController,
//                                     loggedUser: loggedUser,
//                                     servicesFactory: ServicesFactoryStub(userDefaultsStore: store))
//        sut.start()
//
//        return sut
//    }
//
//    private func checkAndGetViewController(at index: Int, file: StaticString = #filePath, line: UInt = #line) throws -> UIViewController? {
//        let tabController = try makeSUT(navigationController: navigationController, alias: .alice).tabBarController
//        let vcs = try unwrap(tabController.viewControllers)
//        assertThat(index < vcs.count, isTrue(), file: file, line: line)
//        let nav = try unwrap(vcs[index] as? UINavigationController)
//        return nav.viewControllers.first
//    }
//
//    // MARK: - Doubles
//
//    private class MainCoordinatorSpy: MainCoordinator {
//
//        private(set) var goToMainPageCalls: [Void] = [Void]()
//        private(set) var onUpdateContactCalls: [Contact] = [Contact]()
//
//        override func goToMainPage() {
//            super.goToMainPage()
//            goToMainPageCalls.append(())
//        }
//    }
//}
//
//extension MainCoordinator {
//
//    var settingsCoordinator: SettingsCoordinator? {
//        children.compactMap({ $0 as? SettingsCoordinator}).first
//    }
//}
