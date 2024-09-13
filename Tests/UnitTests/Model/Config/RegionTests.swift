// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class RegionTests: UnitTestCase {

    private typealias SUT = Config.Region

    func testLosslessString() {
        assertThat(SUT("europe"), equalTo(.europe))
        assertThat(SUT("EUROPE"), equalTo(.europe))
        assertThat(SUT("eu"), equalTo(.europe))
        assertThat(SUT("india"), equalTo(.india))
        assertThat(SUT("INDIA"), equalTo(.india))
        assertThat(SUT("in"), equalTo(.india))
        assertThat(SUT("us"), equalTo(.us))
        assertThat(SUT("middleEast"), equalTo(.middleEast))
        assertThat(SUT("MIDDLEEAST"), equalTo(.middleEast))
        assertThat(SUT("me"), equalTo(.middleEast))
    }

    func testAvailableEnvironments() {
        SUT.allCases.forEach { config in
            switch config {
                case .europe:
                    assertThat(config.availableEnvironments, equalTo(Config.Environment.allCases))
                case .india:
                    assertThat(config.availableEnvironments, equalTo([.production]))
                case .us:
                    assertThat(config.availableEnvironments, equalTo([.production]))
                case .middleEast:
                    assertThat(config.availableEnvironments, equalTo([.production]))
            }
        }
    }
}
