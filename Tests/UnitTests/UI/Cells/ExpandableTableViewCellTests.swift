// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class ExpandableTableViewCellTests: UnitTestCase {

    func testExpandShouldShowDividerAndExpandedContainer() {
        let sut = makeSUT()

        sut.expand()

        assertThat(sut.expandedContainer?.isHidden, presentAnd(isFalse()))
    }

    func testCollapseShouldHideDividerAndExpandedContainer() {
        let sut = makeSUT()

        sut.expand()
        sut.collapse()

        assertThat(sut.expandedContainer?.isHidden, presentAnd(isTrue()))
    }

    // MARK: - Helpers

    private func makeSUT() -> ExpandableTableViewCell {
        .init(style: .default, reuseIdentifier: nil)
    }
}

private extension ExpandableTableViewCell {

    var expandedContainer: UIView? {
        firstDescendant(identifiedBy: "bottomContainer")
    }
}
