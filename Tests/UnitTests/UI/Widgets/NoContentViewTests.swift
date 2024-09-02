// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class NoContentViewTests: UnitTestCase {

    func testShouldTriggerActionWhenButtonIsTouched() throws {
        let completionSpy = CompletionSpy<Void>()
        let sut = NoContentView(style: .action(title: .foo, subtitle: .bar, actionTitle: .baz, action: completionSpy.callAsFunction), header: UIView())

        let button: UIButton? = sut.firstDescendant()
        assertThat(button, present())
        button?.simulateTap()

        assertThat(completionSpy.invocations, hasCount(1))
    }
}
