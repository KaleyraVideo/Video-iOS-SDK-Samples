// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class SettingsCellTests: UnitTestCase {

    func testInitShouldSetupBackgroundView() {
        let sut = SettingsCell()

        assertThat(sut.selectedBackgroundView, present())
        assertThat(sut.selectedBackgroundView?.backgroundColor, presentAnd(equalTo(.lightGray)))
    }

    func testInitShouldSetupLabelsCorrectly() {
        let sut = SettingsCell()

        assertThat(sut.textLabel?.font, presentAnd(equalTo(.systemFont(ofSize: 18))))
        assertThat(sut.detailTextLabel?.font, presentAnd(equalTo(.systemFont(ofSize: 16))))
    }

#if SAMPLE_CUSTOMIZABLE_THEME

    func testThemableBehaviour() {
        let font = UIFont(name: "HelveticaNeue-Thin", size: 17)!
        let sut = SettingsCell()
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
        let sut = SettingsCell()
        let theme = AppTheme()

        theme.primaryBackgroundColor.setValues(from: .white)
        sut.themeChanged(theme: theme)

        assertThat(sut.textLabel?.textColor, presentAnd(equalTo(.black)))
        assertThat(sut.detailTextLabel?.textColor, presentAnd(equalTo(.gray)))
    }

    func testDarkBackgroundColorShouldSetLightTextColor() {
        let sut = SettingsCell()
        let theme = AppTheme()

        theme.primaryBackgroundColor.setValues(from: .black)
        sut.themeChanged(theme: theme)

        assertThat(sut.textLabel?.textColor, presentAnd(equalTo(.white)))
        assertThat(sut.detailTextLabel?.textColor, presentAnd(equalTo(.lightGray)))
    }
#endif

    func testChangeTheCellStyleToDangerShouldChangeTextLabelTextColorToRed() {
        let sut = SettingsCell()

        sut.cellStyle = .danger

        assertThat(sut.textLabel?.textColor, presentAnd(equalTo(.red)))
    }
}
