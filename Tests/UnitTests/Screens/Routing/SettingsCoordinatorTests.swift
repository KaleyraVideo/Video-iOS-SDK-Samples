// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class SettingsCoordinatorTests: UnitTestCase {

    private var delegate: DelegateSpy!
    private var sut: SettingsCoordinator!

    override func setUp() {
        super.setUp()

        delegate = .init()
        sut = .init(session: .init(config: .init(keys: .any), 
                                   user: .init(alias: .alice),
                                   contactsStore: .init(repository: UserRepositoryDummy())),
                    services: ServicesFactoryStub(), delegate: delegate)
    }

    override func tearDown() {
        sut = nil
        delegate = nil
        super.tearDown()
    }

    func testOpenThemeShouldPushAThemeViewControllerInTheNavigationStack() {
        sut.settingsViewControllerDidOpenTheme()

        assertThat(sut.navigationController.viewControllers, hasCount(1))
        assertThat(sut.navigationController.viewControllers.last as? ThemeViewController, present())
    }

    func testOpenThemeShouldAddChildrenToCoordinator() {
        sut.settingsViewControllerDidOpenTheme()

        assertThat(sut.children, hasCount(1))
    }

    func testOnLogoutMethodShouldCallSettingsCoordinatorDelegateMethod() {
        sut.settingsViewControllerDidLogout()

        assertThat(delegate.logoutInvocations, hasCount(1))
    }

    func testOnContactSelectedShouldAddProfileCoordinatorToHierarchy() {
        sut.settingsViewControllerDidUpdateUser(contact: .init(alias: .bob))

        assertThat(sut.children, hasCount(1))
        assertThat(sut.children[0], instanceOf(ContactProfileCoordinator.self))
    }

    func testCreatesNavigationControllerWithSettingViewControllerAsRoot() {
        sut.start()

        assertThat(sut.navigationController.viewControllers.first, presentAnd(instanceOf(SettingsViewController.self)))
    }

    // MARK: - Doubles

    private class DelegateSpy: SettingsCoordinatorDelegate {

        private(set) lazy var logoutInvocations: [Void] = []
        private(set) lazy var resetInvocations: [Void] = []

        func settingsCoordinatorDidLogout() {
            logoutInvocations.append()
        }

        func settingsCoordinatorDidReset() {
            resetInvocations.append()
        }
    }
}
