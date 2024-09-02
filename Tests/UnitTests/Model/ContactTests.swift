// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class ContactTests: UnitTestCase {

    func testInitializationOfContactWithAliasAndGender() {
        let sut = Contact("arc")

        XCTAssertEqual(sut.gender, Contact.Gender.unknown)
        XCTAssertEqual(sut.alias, "arc")
    }

}
