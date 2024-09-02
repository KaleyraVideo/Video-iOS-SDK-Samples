// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class LoginStringsTests: UnitTestCase {

    func testSearchPlaceholder() {
        assertThat(Strings.Login.searchPlaceholder, equalTo(NSLocalizedString("login.search_placeholder", comment: "")))
    }

    func testTitle() {
        assertThat(Strings.Login.title, equalTo(NSLocalizedString("login.title", comment: "")))
    }

}
