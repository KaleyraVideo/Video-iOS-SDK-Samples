// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME
final class UINavigationController_ExtTests: UnitTestCase {

    func testThemeChangedMethodShoulSetUpNavigationControllerElementsAccordingly() {
        let sut = UINavigationController()
        let theme = makeTheme()

        sut.themeChanged(theme: theme)

        assertThat(sut.navigationBar.barTintColor, equalTo(theme.barTintColor?.toUIColor()))
        assertThat(sut.navigationBar.titleTextAttributes, presentAnd(hasKey(NSAttributedString.Key.font)))
        assertThat(sut.navigationBar.largeTitleTextAttributes, presentAnd(hasKey(NSAttributedString.Key.font)))
        assertThat(sut.navigationBar.titleTextAttributes?[NSAttributedString.Key.font] as? UIFont, presentAnd(equalTo(theme.navBarTitleFont!.toUIFont())))
        assertThat(sut.navigationBar.largeTitleTextAttributes?[NSAttributedString.Key.font] as? UIFont, presentAnd(equalTo(theme.navBarTitleFont!.toUIFont().withSize(theme.largeFontPointSize))))
        assertThat(sut.navigationBar.barStyle, equalTo(theme.barStyle))
        assertThat(sut.navigationBar.isTranslucent, equalTo(theme.barTranslucent))
        assertThat(sut.navigationBar.tintColor, equalTo(theme.accentColor.toUIColor()))
    }

    func testThemeChangedMethodShouldPropagateThemeChangedToItsNavigationStackViewControllerIfThemable() {
        let sut = UINavigationController()
        let child1 = ThemableViewControllerSpy()
        let child2 = ThemableViewControllerSpy()
        let theme = makeTheme()

        sut.setViewControllers([child1, child2], animated: false)
        sut.themeChanged(theme: theme)

        assertThat(child1.appliedThemes, hasCount(1))
        assertThat(child1.appliedThemes.first, presentAnd(sameInstance(theme)))
        assertThat(child2.appliedThemes, hasCount(1))
        assertThat(child2.appliedThemes.first, presentAnd(sameInstance(theme)))
    }

    func testLightNavBarBgColorShouldSetBlackNavBarTitleColor() {
        let sut = UINavigationController()
        let theme = makeTheme()
        theme.barTintColor = AppThemeColor(from: .white)

        sut.themeChanged(theme: theme)

        assertThat(sut.navigationBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor, presentAnd(equalTo(.black)))
    }

    func testDarkNavBarBgColorShouldSetWhiteNavBarTitleColor() {
        let sut = UINavigationController()
        let theme = makeTheme()
        theme.barTintColor = AppThemeColor(from: .black)

        sut.themeChanged(theme: theme)

        assertThat(sut.navigationBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor, presentAnd(equalTo(.white)))
    }

    func testLightPrimaryBgColorShouldSetBlackNavBarTitleColor() {
        let sut = UINavigationController()
        let theme = makeTheme()
        theme.secondaryBackgroundColor = AppThemeColor(from: .white)

        sut.themeChanged(theme: theme)

        assertThat(sut.navigationBar.largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor, presentAnd(equalTo(.black)))
    }

    func testDarkPrimaryBgColorShouldSetWhiteNavBarTitleColor() {
        let sut = UINavigationController()
        let theme = makeTheme()
        theme.secondaryBackgroundColor = AppThemeColor(from: .black)

        sut.themeChanged(theme: theme)

        assertThat(sut.navigationBar.largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor, presentAnd(equalTo(.white)))
    }

    // MARK: - Helpers

    private func makeTheme() -> AppTheme {
        let appTheme = AppTheme()
        appTheme.barStyle = .black
        let font = AppThemeFont()
        font.setValues(from: UIFont(name: "avenir-black", size: 20)!)
        appTheme.navBarTitleFont = font
        let color = AppThemeColor()
        color.setValues(from: .green)
        appTheme.barTintColor = color
        appTheme.barTranslucent = false
        return appTheme
    }
}

class ThemableViewControllerSpy: UIViewController, Themable {

    var appliedThemes: [AppTheme] = []

    func themeChanged(theme: AppTheme) {
        appliedThemes.append(theme)
    }
}

#endif
