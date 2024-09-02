// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class CallOptionsTests: UnitTestCase {

    func testDefaultInitialiserSetupObjectWithDefaultValues() {
        let sut = CallOptions()

        assertThat(sut.type, equalTo(.audioVideo))
        assertThat(sut.maximumDuration, equalTo(0))
        assertThat(sut.recording, equalTo(.none))
        assertThat(sut.isGroup, isFalse())
        assertThat(sut.showsRating, isFalse())
        assertThat(sut.presentationMode, equalTo(.fullscreen))
    }
}
