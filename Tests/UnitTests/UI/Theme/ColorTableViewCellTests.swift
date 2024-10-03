// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

@available(iOS 15.0, *)
final class ColorTableViewCellTests: UnitTestCase {

    private var sut: ColorTableViewCell!

    override func setUp() {
        super.setUp()

        sut = .init(style: .default, reuseIdentifier: nil)
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    // MARK: - Init

    func testInitShouldAddLabelToContentViewHierarchy() {
        assertThat(sut.label, present())
        assertThat(sut.label.textAlignment, equalTo(.left))
        assertThat(sut.label.isDescendant(of: sut.contentView), isTrue())
    }

    func testInitShouldAddColorPreviewViewToContentViewHierarchy() {
        assertThat(sut.colorWell, present())
        assertThat(sut.colorWell.isDescendant(of: sut.contentView), isTrue())
    }

    // MARK: - Getters and setters

    func testSetTitleShouldUpdateLabelText() {
        sut.title = "foo"

        assertThat(sut.label.text, equalTo("foo"))
    }

    func testGetTitleShouldReturnLabelText() {
        sut.label.text = "foo"

        assertThat(sut.title, equalTo("foo"))
    }

    func testSetColorShouldUpdateColorPreviewViewBackgroundColor() {
        sut.color = .red

        assertThat(sut.colorWell.selectedColor, equalTo(.red))
    }

    func testGetColorShouldReturnColorPreviewViewBackgroundColor() {
        sut.colorWell.selectedColor = .red

        assertThat(sut.color, equalTo(.red))
    }

    // MARK: - Prepare for reuse

    func testPrepareForReuseShouldResetTitleAndColor() {
        sut.color = .red
        sut.title = "foo"

        sut.prepareForReuse()

        assertThat(sut.title, nilValue())
        assertThat(sut.color, nilValue())
    }
}

@available(iOS 15.0, *)
private extension ColorTableViewCell {

    var label: UILabel! {
        firstDescendant()
    }

    var colorWell: UIColorWell! {
        firstDescendant()
    }
}
