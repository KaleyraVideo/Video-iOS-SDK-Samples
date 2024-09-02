// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class ColorPreviewViewTests: UnitTestCase {

    private var sut: ColorPreviewView!

    override func setUpWithError() throws {
        try super.setUpWithError()

        sut = ColorPreviewView()
    }

    func testSetBorderColorUpdateLayerBorderColor() {
        sut.borderColor = .red

        assertThat(sut.layer.borderColor, equalTo(UIColor.red.cgColor))
    }

    func testGetBorderColorShouldReturnLayerBorderColor() {
        sut.layer.borderColor = UIColor.red.cgColor

        assertThat(sut.borderColor, equalTo(.red))
    }

    func testSetBorderWidthUpdateLayerBorderWidth() {
        sut.borderWidth = 4

        assertThat(sut.layer.borderWidth, equalTo(CGFloat(4)))
    }

    func testGetBorderWidthShouldReturnLayerBorderWidth() {
        sut.layer.borderWidth = 4

        assertThat(sut.borderWidth, equalTo(CGFloat(4)))
    }

    func testsetUpColorMethodShouldAddImageViewWhenColorIsNil() {
        sut.setUpColor(nil)

        assertThat(sut.backgroundColView, present())
        assertThat(sut.backgroundColView!.isDescendant(of: sut), isTrue())
    }

    func testsetUpColorMethodShouldRemoveImageViewWhenColorIsPresent() {
        sut.setUpColor(.systemPink)

        assertThat(sut.backgroundColView, equalTo(nil))

    }
}

extension ColorPreviewView {

    var backgroundColView: UIImageView? {
        self.firstDescendant()
    }

}
