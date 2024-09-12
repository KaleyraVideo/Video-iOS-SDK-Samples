// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class CallSettingsCoordinatorTests: UnitTestCase {

    func testCreatesNavigationControllerWithCallOptionsTableViewControllerAsRoot() throws {
        let sut = makeSUT()

        let controller = sut.controller

        assertThat(controller, instanceOf(UINavigationController.self))
        assertThat(controller.children.first, presentAnd(instanceOf(CallSettingsViewController.self)))
    }

    func testComposeSetsNavigationItemPrefersLargeTitleToTrue() throws {
        let sut = makeSUT()

        let controller = sut.controller

        let navController = controller as? UINavigationController
        assertThat(navController?.navigationBar.prefersLargeTitles, presentAnd(isTrue()))
    }

    // MARK: - Helpers

    private func makeSUT() -> CallSettingsCoordinator {
        .init(appSettings: .init(), services: ServicesFactoryStub())
    }
}
