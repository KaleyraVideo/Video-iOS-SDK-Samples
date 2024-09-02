// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ThemeCellTests: UnitTestCase {

    func testInitShouldSetupBackgroundView() {
        let sut = ThemeCell()

        assertThat(sut.selectedBackgroundView, present())
    }

    func testThemableBehaviour() {
        let font = UIFont(name: "HelveticaNeue-Thin", size: 17)!
        let sut = ThemeCell()
        let theme = AppTheme()

        theme.accentColor.setValues(from: .purple)
        theme.primaryBackgroundColor.setValues(from: .blue)
        theme.tertiaryBackgroundColor.setValues(from: .red)
        theme.font = AppThemeFont(from: font)
        sut.themeChanged(theme: theme)

        assertThat(sut.backgroundColor, equalTo(.blue))
        assertThat(sut.selectedBackgroundView?.backgroundColor, presentAnd(equalTo(.red)))
        assertThat(sut.tintColor, equalTo(.purple))
        assertThat(sut.textLabel?.font, presentAnd(equalTo(font)))
    }

    func testLightBackgroundColorShouldSetBlackTextColor() {
        let sut = ThemeCell()
        let theme = AppTheme()

        theme.primaryBackgroundColor.setValues(from: .white)
        sut.themeChanged(theme: theme)

        assertThat(sut.textLabel?.textColor, presentAnd(equalTo(.black)))
    }

    func testDarkBackgroundColorShouldSetLightTextColor() {
        let sut = ThemeCell()
        let theme = AppTheme()

        theme.primaryBackgroundColor.setValues(from: .black)
        sut.themeChanged(theme: theme)

        assertThat(sut.textLabel?.textColor, presentAnd(equalTo(.white)))
    }
}

#endif
