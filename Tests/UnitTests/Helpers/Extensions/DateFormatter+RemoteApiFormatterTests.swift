// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

@available(iOS 12.0, *)
final class DateFormatter_RemoteApiFormatterTests: UnitTestCase {

    func testChatDateFormatterShouldReturnDateFormatterWithUTCTimeZoneAndExtendedISO8601DateFormat() {
        let sut = DateFormatter.remoteApiFormatter

        assertThat(sut.timeZone, equalTo(.UTC))
        assertThat(sut.dateFormat, equalTo("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"))
    }
}
