// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class ContactUpdateTableViewControllerUITests: SnapshotTestCase {

    func testAppearanceOfContactsUpdateItems() {
        let contact = Contact("testAlias")
#if SAMPLE_CUSTOMIZABLE_THEME
        let sut = ContactUpdateTableViewController(contact: contact, themeStorage: DummyThemeStorage())
#else
        let sut = ContactUpdateTableViewController(contact: contact)
#endif
        let _ = sut.view

        verifySnapshot(sut)
    }

}
