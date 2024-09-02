// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
import UIKit
@testable import SDK_Sample

final class AppThemeFontTests: UnitTestCase {

    func testSetValuesFromUIFontShouldSetFontComponentsValueToRespectiveProperties() {
        let sut = AppThemeFont()
        let font = UIFont(name: "HelveticaNeue-Thin", size: 17)!

        sut.setValues(from: font)

        assertThat(sut.fontName, equalTo("HelveticaNeue-Thin"))
        assertThat(sut.pointSize, equalTo(17))
    }

    func testToUIFontShouldReturnTheCorrectUIFont() {
        let sut = AppThemeFont()
        sut.fontName = "HelveticaNeue-Thin"
        sut.pointSize = 17

        let font = sut.toUIFont()

        assertThat(font, equalTo(UIFont(name: "HelveticaNeue-Thin", size: 17)))
    }

    func testFontNameNotPresentShouldReturnSystemFont() {
        let sut = AppThemeFont()
        sut.fontName = "_font_not_present_"
        sut.pointSize = 17

        let font = sut.toUIFont()

        assertThat(font, equalTo(UIFont.systemFont(ofSize: 17)))
    }

    func testPointSizeNegativeShouldReturnFontWithSystemFontPointSize() {
        let sut = AppThemeFont()
        sut.fontName = "HelveticaNeue-Thin"
        sut.pointSize = -17

        let font = sut.toUIFont()

        assertThat(font, equalTo(UIFont(name: "HelveticaNeue-Thin", size: UIFont.systemFontSize)))
    }

    func testPointSizeEqualToZeroShouldReturnFontWithZeroPointSize() {
        let sut = AppThemeFont()
        sut.fontName = "HelveticaNeue-Thin"
        sut.pointSize = 0

        let font = sut.toUIFont()

        assertThat(font, equalTo(UIFont(name: "HelveticaNeue-Thin", size: 0)))
    }

    func testInitFromUIFontShouldSetFontComponentsValueToRespectiveProperties() {
        let font = UIFont(name: "HelveticaNeue-Thin", size: 17)!
        let sut = AppThemeFont(from: font)

        assertThat(sut.fontName, equalTo("HelveticaNeue-Thin"))
        assertThat(sut.pointSize, equalTo(17))
    }
}
