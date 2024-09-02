// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ColorTableViewCellTests: UnitTestCase {

    // MARK: - Init

    func testInitShouldAddLabelToContentViewHierarchy() {
        let sut = makeSUT()

        let labels = sut.contentView.subviews.compactMap({ $0 as? UILabel })
        assertThat(labels, hasCount(1))
    }

    func testInitShouldAddLabelWithLeftTextAlignment() {
        let sut = makeSUT()

        assertThat(sut.label.textAlignment, equalTo(.left))
    }

    func testInitShouldAddColorPreviewViewToContentViewHierarchy() {
        let sut = makeSUT()

        let colorPreviewViews = sut.contentView.subviews.compactMap({ $0 as? ColorPreviewView })
        assertThat(colorPreviewViews, hasCount(1))
    }

    func testSetUpFontShouldActAccordingly() {
        let sut = makeSUT()

        let font = UIFont(name: "avenir-black", size: 13)!
        sut.setUpLabelFont(font: font)

        assertThat(sut.label.font, equalTo(font))

    }

    // MARK: - Getters and setters

    func testSetTitleShouldUpdateLabelText() {
        let sut = makeSUT()

        sut.title = "foo"

        assertThat(sut.label.text, equalTo("foo"))
    }

    func testGetTitleShouldReturnLabelText() {
        let sut = makeSUT()

        sut.label.text = "foo"

        assertThat(sut.title, equalTo("foo"))
    }

    func testSetColorShouldUpdateColorPreviewViewBackgroundColor() {
        let sut = makeSUT()

        sut.color = .red

        assertThat(sut.colorPreview.backgroundColor, equalTo(.red))
    }

    func testGetColorShouldReturnColorPreviewViewBackgroundColor() {
        let sut = makeSUT()

        sut.colorPreview.backgroundColor = .red

        assertThat(sut.color, equalTo(.red))
    }

    // MARK: - Prepare for reuse

    func testPrepareForReuseShouldResetTitleAndColor() {
        let sut = makeSUT()
        sut.color = .red
        sut.title = "foo"

        sut.prepareForReuse()

        assertThat(sut.title, nilValue())
        assertThat(sut.color, nilValue())
    }

    // MARK: - Helpers

    private func makeSUT() -> ColorTableViewCell {
        ColorTableViewCell()
    }
}

private extension ColorTableViewCell {

    var label: UILabel! {
        firstDescendant()
    }

    var colorPreview: ColorPreviewView! {
        firstDescendant()
    }
}
