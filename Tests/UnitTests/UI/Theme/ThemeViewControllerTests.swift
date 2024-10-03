// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

@available(iOS 15.0, *)
final class ThemeViewControllerTests: UnitTestCase {

    private var sut: ThemeViewController!

    override func setUp() {
        super.setUp()

        sut = .init(sdk: .instance)
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testLoadViewShouldSetupTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, presentAnd(equalTo(NSLocalizedString("settings.change_theme", comment: "Change theme"))))
    }
}
