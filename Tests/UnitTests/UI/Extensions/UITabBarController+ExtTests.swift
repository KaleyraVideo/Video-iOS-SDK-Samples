// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME
final class UITabBarController_ExtTests: UnitTestCase, ConditionalTestCase {

    func testChangeThemeMethodShouldChangeThemeOniOS12AndOlder() throws {
        try run(ifVersionBelow: 13, "SFSymbols is not available on iOS version lower than 13 ") {
            let sut = UITabBarController()
            let theme = makeTheme()

            sut.themeChanged(theme: theme)

            assertThat(sut.tabBar.tintColor, equalTo(theme.accentColor.toUIColor()))
            assertThat(sut.tabBar.barTintColor, equalTo(theme.barTintColor!.toUIColor()))
            assertThat(sut.tabBar.isTranslucent, isFalse())
        }
    }

    @available(iOS 13.0, *)
    func testChangeThemeMethodShouldChangeThemeOniOS13AndNewer() throws {
        try run(ifVersionAtLeast: 13, "SFSymbols is not available on iOS version lower than 13 ") {
            let sut = UITabBarController()
            let theme = makeTheme()

            sut.themeChanged(theme: theme)

            assertThat(sut.tabBar.standardAppearance.backgroundColor, presentAnd(equalTo(theme.barTintColor!.toUIColor())))
            assertThat(sut.tabBar.standardAppearance.selectionIndicatorTintColor, presentAnd(equalTo(theme.barTintColor!.toUIColor())))
            assertThat(sut.tabBar.isTranslucent, isFalse())
        }
    }

    func testChangeThemeShouldPropagateTheEventToAllItsChildViewControllers() {
        let sut = UITabBarController()
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

    private func makeTheme() -> AppTheme {
        let appTheme = AppTheme()

        let accentColor = AppThemeColor()
        accentColor.setValues(from: .blue)
        appTheme.accentColor = accentColor

        let barColor = AppThemeColor()
        barColor.setValues(from: .blue)
        appTheme.barTintColor = barColor

        appTheme.barTranslucent = false

        return appTheme
    }
}
#endif
