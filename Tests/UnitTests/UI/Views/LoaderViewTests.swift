// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class LoaderViewTests: UnitTestCase {

    func testStartAnimatingSetsIsAnimatingToTrue() {
        let sut = LoaderView(image: Icons.logo256)

        sut.startAnimating(with: 1)

        assertThat(sut.isAnimating, isTrue())
    }

    func testStopAnimatingSetsIsAnimatingToFalse() {
        let sut = LoaderView(image: Icons.logo256)

        sut.startAnimating(with: 1)
        sut.stopAnimating()

        assertThat(sut.isAnimating, isFalse())
    }
}
