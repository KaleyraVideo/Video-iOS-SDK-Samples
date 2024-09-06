// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class ContactProfileCoordinatorTests: UnitTestCase {

    func testCreatesNavigationControllerWithContactUpdateTableViewControllerAsRoot() throws {
        let sut = makeSUT()

        let navController = try unwrap(sut.controller as? UINavigationController)
        assertThat(navController.viewControllers.first as Any, instanceOf(ContactUpdateTableViewController.self))
    }

    func testComposeSetsNavigationItemPrefersLargeTitleToTrue() throws {
        let sut = makeSUT()

        let navController = try unwrap(sut.controller as? UINavigationController)
        assertThat(navController.navigationBar.prefersLargeTitles, isTrue())
    }

    // MARK: - Helpers

    private func makeSUT() -> ContactProfileCoordinator {
        .init(contact: Contact(.alice), store: ContactsStore(repository: UserRepositoryDummy()), services: ServicesFactoryStub())
    }
}
