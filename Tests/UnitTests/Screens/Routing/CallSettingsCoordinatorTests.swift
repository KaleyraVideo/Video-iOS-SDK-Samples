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

        assertThat(sut.controller.children.first, presentAnd(instanceOf(CallSettingsViewController.self)))
    }

    func testComposeSetsNavigationItemPrefersLargeTitleToTrue() throws {
        let sut = makeSUT()

        assertThat(sut.controller.navigationBar.prefersLargeTitles, presentAnd(isTrue()))
    }

    // MARK: - Helpers

    private func makeSUT() -> CallSettingsCoordinator {
        .init(appSettings: .init(repository: SettingsRepositoryDummy()), services: ServicesFactoryStub())
    }
}
