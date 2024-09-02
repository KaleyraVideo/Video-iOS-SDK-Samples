// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class EnvironmentTests: UnitTestCase {

    func testInitFromString() {
        assertThat(Config.Environment(rawValue: "production"), equalTo(.production))
        assertThat(Config.Environment(rawValue: "sandbox"), equalTo(.sandbox))

#if DEBUG
        assertThat(Config.Environment(rawValue: "develop"), equalTo(.development))
        assertThat(Config.Environment(rawValue: "development"), equalTo(.development))
#endif
    }

    func testEnvironmentsForRegion() {
        assertThat(Config.Environment.environmentsFor(region: .europe), equalTo(Config.Environment.allCases))
        assertThat(Config.Environment.environmentsFor(region: .india), equalTo([.production]))
        assertThat(Config.Environment.environmentsFor(region: .us), equalTo([.production]))
    }
}
