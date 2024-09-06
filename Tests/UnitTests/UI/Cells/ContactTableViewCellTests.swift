// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ContactTableViewCellTests: UnitTestCase {

#if SAMPLE_CUSTOMIZABLE_THEME

    func testThemableBehavior() {
        let sut = ContactTableViewCell()
        let theme = AppTheme.defaultDarkTheme()
        let font = UIFont(name: "HelveticaNeue-Thin", size: 17)!
        let secondaryFont = UIFont(name: "HelveticaNeue-Bold", size: 12)!
        theme.font = AppThemeFont(from: font)
        theme.secondaryFont = AppThemeFont(from: secondaryFont)

        sut.themeChanged(theme: theme)

        assertThat(sut.backgroundColor, presentAnd(equalTo(theme.primaryBackgroundColor.toUIColor())))
        assertThat(sut.nameLabel?.font, presentAnd(equalTo(font)))
        assertThat(sut.aliasLabel?.font, presentAnd(equalTo(secondaryFont)))
    }

    func testLightPrimaryBgColorShouldSetBlackLabelsTextColor() {
        let sut = ContactTableViewCell()
        let theme = AppTheme()
        theme.primaryBackgroundColor = AppThemeColor(from: .white)

        sut.themeChanged(theme: theme)

        assertThat(sut.nameLabel?.textColor, presentAnd(equalTo(.black)))
        assertThat(sut.aliasLabel?.textColor, presentAnd(equalTo(.black)))
    }

    func testDarkPrimaryBgColorShouldSetWhiteLabelsTextColor() {
        let sut = ContactTableViewCell()
        let theme = AppTheme()
        theme.primaryBackgroundColor = AppThemeColor(from: .black)

        sut.themeChanged(theme: theme)

        assertThat(sut.nameLabel?.textColor, presentAnd(equalTo(.white)))
        assertThat(sut.aliasLabel?.textColor, presentAnd(equalTo(.white)))
    }
#endif

}

private extension ContactTableViewCell {

    var contactNameLabel: UILabel? {
        contentView.firstDescendant(identifiedBy: "__contact_name_label__")
    }

    var contactAliasLabel: UILabel? {
        contentView.firstDescendant(identifiedBy: "__contact_alias_label__")
    }
}
