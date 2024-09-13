// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class EnvironmentTests: UnitTestCase {

    private typealias SUT = Config.Environment

    func testInitFromString() {
        assertThat(SUT("production"), equalTo(.production))
        assertThat(SUT("PRODUCTION"), equalTo(.production))
        assertThat(SUT("prod"), equalTo(.production))
        assertThat(SUT("sandbox"), equalTo(.sandbox))
        assertThat(SUT("SANDBOX"), equalTo(.sandbox))
        assertThat(SUT("develop"), equalTo(.development))
        assertThat(SUT("development"), equalTo(.development))
        assertThat(SUT("DEVELOPMENT"), equalTo(.development))
    }
}
