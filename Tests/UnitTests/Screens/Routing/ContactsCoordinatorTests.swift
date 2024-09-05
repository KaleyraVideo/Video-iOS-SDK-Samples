// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class ContactsCoordinatorTests: UnitTestCase {

    func testComposeDoesNotCreateRetainCycles() throws {
        let sut = makeSUT()
        sut.start(onCallOptionsChanged: {_ in }, onCallUser: {_ in })

        let navController = sut.navigationController
        let controller = try unwrap(navController.contactsViewController)

        assertDeallocatedOnTeardown(sut)
        assertDeallocatedOnTeardown(controller)
        assertDeallocatedOnTeardown(navController)
    }

    // MARK: - Helpers

    private func makeSUT() -> ContactsCoordinator {
        .init(config: .init(keys: .any), loggedUser: .init(.alice), services: ServicesFactoryStub())
    }
}

private extension UINavigationController {

    var contactsViewController: ContactsViewController? {
        viewControllers.first as? ContactsViewController
    }
}
