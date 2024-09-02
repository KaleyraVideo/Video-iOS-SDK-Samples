// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class ContactsViewControllerUITests: SnapshotTestCase {

#if SAMPLE_CUSTOMIZABLE_THEME
    let sut = ContactsViewController(themeStorage: DummyThemeStorage())
#else
    let sut = ContactsViewController()
#endif

    func testEmptyDatasetUser() {
        let _ = sut.view

        sut.display(contacts: [])

        verifySnapshot(sut)
    }

    func testShowCorrectlyValuesOnTableView() {
        let _ = sut.view

        let contactsGenerator = ContactsGenerator(seed: UInt64(100))
        sut.display(contacts: [contactsGenerator.contact("Pippo"), contactsGenerator.contact("Pluto")])

        verifySnapshot(sut)
    }
}
