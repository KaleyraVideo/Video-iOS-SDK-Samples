// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME
final class AppThemeTests: UnitTestCase {

    func testSelectedValueChangeShouldInvokeSelectedChangedClosure() {
        let sut = AppTheme()
        var invoked = false

        sut.selectedChanged = { _ in
            invoked = true
        }
        sut.selected = true

        assertThat(invoked, isTrue())
    }

    func testSelectedValueChangeShouldPassTheNewValueToSelectedChangedClosure() {
        let sut = AppTheme()
        var newVal: Bool?

        sut.selectedChanged = { val in
            newVal = val
        }

        sut.selected = true
        assertThat(newVal, presentAnd(isTrue()))

        sut.selected = false
        assertThat(newVal, presentAnd(isFalse()))
    }

    func testVariablesOfAppThemeShouldBeKeyvalueCompliant() {
        let sut = AppTheme()
        let blueColor = AppThemeColor()
        blueColor.setValues(from: .blue)
        let themeFont = AppThemeFont()
        themeFont.setValues(from: UIFont(name: "avenir-black", size: 20)!)

        sut.setValue(blueColor, forKey: "accentColor")
        sut.setValue(blueColor, forKey: "primaryBackgroundColor")
        sut.setValue(blueColor, forKey: "secondaryBackgroundColor")
        sut.setValue(blueColor, forKey: "tertiaryBackgroundColor")
        sut.setValue(blueColor, forKey: "barTintColor")
        sut.setValue(themeFont, forKey: "navBarTitleFont")
        sut.setValue(themeFont, forKey: "barItemFont")
        sut.setValue(themeFont, forKey: "bodyFont")
        sut.setValue(themeFont, forKey: "font")
        sut.setValue(themeFont, forKey: "emphasisFont")
        sut.setValue(themeFont, forKey: "secondaryFont")
        sut.setValue(10, forKey: "mediumFontPointSize")
        sut.setValue(20, forKey: "largeFontPointSize")
        sut.setValue(true, forKey: "barTranslucent")
        sut.setValue(0, forKey: "barStyle")

        assertThat(sut.accentColor, equalTo(blueColor))
        assertThat(sut.primaryBackgroundColor, equalTo(blueColor))
        assertThat(sut.secondaryBackgroundColor, equalTo(blueColor))
        assertThat(sut.tertiaryBackgroundColor, equalTo(blueColor))
        assertThat(sut.barTintColor, equalTo(blueColor))
        assertThat(sut.barTranslucent, equalTo(true))
        assertThat(sut.navBarTitleFont, equalTo(themeFont))
        assertThat(sut.barItemFont, equalTo(themeFont))
        assertThat(sut.bodyFont, equalTo(themeFont))
        assertThat(sut.font, equalTo(themeFont))
        assertThat(sut.emphasisFont, equalTo(themeFont))
        assertThat(sut.secondaryFont, equalTo(themeFont))
        assertThat(sut.mediumFontPointSize, equalTo(10))
        assertThat(sut.largeFontPointSize, equalTo(20))
        assertThat(sut.barStyle, equalTo(UIBarStyle.default))
    }

    func testSetValueForKeyShouldStoreProvidedValueCorrectlyWhenValueIsAUIBarStyle() {
        let sut = AppTheme()

        sut.barStyle = .default
        sut.setValue(UIBarStyle.black, forKey: "barStyle")

        assertThat(sut.barStyle, equalTo(.black))
    }

    func testSetValueForKeyShouldStoreProvidedValueCorrectlyWhenValueIsAUIKeyboardAppearance() {
        let sut = AppTheme()

        sut.keyboardAppearance = .default
        sut.setValue(UIKeyboardAppearance.dark, forKey: "keyboardAppearance")

        assertThat(sut.keyboardAppearance, equalTo(.dark))
    }

    func testSetValueForKeyShouldStoreProvidedValueCorrectlyWhenValueIsNonRawRepresentable() {
        let sut = AppTheme()
        let appThemeColor = AppThemeColor()

        sut.setValue(appThemeColor, forKey: "accentColor")

        assertThat(sut.accentColor, sameInstance(appThemeColor))
    }

    func testSetValueForKeyShouldStoreProvidedValueCorrectlyWhenValueIsAnyContainingUIBarStyle() {
        let sut = AppTheme()
        let newValue: Any = UIBarStyle.black

        sut.barStyle = .default
        sut.setValue(newValue, forKey: "barStyle")

        assertThat(sut.barStyle, equalTo(.black))
    }

    func testSetValueForKeyShouldStoreProvidedValueCorrectlyWhenValueIsAnyContainingUIKeyboardAppearance() {
        let sut = AppTheme()
        let newValue: Any = UIKeyboardAppearance.dark

        sut.keyboardAppearance = .default
        sut.setValue(newValue, forKey: "keyboardAppearance")

        assertThat(sut.keyboardAppearance, equalTo(.dark))
    }

    func testDefaultLightThemeFactoryMethodShouldReturnACorrectlyConfiguredObject() {
        let sut = AppTheme.defaultLightTheme()

        assertThat(sut.appearance, equalTo(.light))
        assertThat(sut.accentColor.toUIColor(), equalTo(UIColor(rgb: 0xD80D30)))
        assertThat(sut.primaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 255, g: 255, b: 255)))
        assertThat(sut.secondaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 242, g: 242, b: 242)))
        assertThat(sut.tertiaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 255, g: 227, b: 236)))
        assertThat(sut.barTintColor, nilValue())
        assertThat(sut.barTranslucent, isTrue())
        assertThat(sut.barStyle, equalTo(.default))
        assertThat(sut.navBarTitleFont, nilValue())
        assertThat(sut.barItemFont, nilValue())
        assertThat(sut.bodyFont, nilValue())
        assertThat(sut.font, nilValue())
        assertThat(sut.emphasisFont, nilValue())
        assertThat(sut.secondaryFont, nilValue())
        assertThat(sut.mediumFontPointSize, equalTo(14))
        assertThat(sut.largeFontPointSize, equalTo(22))
    }

    func testDefaultDarkThemeFactoryMethodShouldReturnACorrectlyConfiguredObject() {
        let sut = AppTheme.defaultDarkTheme()

        assertThat(sut.appearance, equalTo(.dark))
        assertThat(sut.accentColor.toUIColor(), equalTo(UIColor(rgb: 0xD80D30)))
        assertThat(sut.primaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 0, g: 0, b: 0)))
        assertThat(sut.secondaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 28, g: 28, b: 28)))
        assertThat(sut.tertiaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 44, g: 44, b: 44)))
        assertThat(sut.barTintColor?.toUIColor(), presentAnd(equalTo(UIColor(r: 0, g: 0, b: 0))))
        assertThat(sut.barTranslucent, isTrue())
        assertThat(sut.barStyle, equalTo(.default))
        assertThat(sut.navBarTitleFont, nilValue())
        assertThat(sut.barItemFont, nilValue())
        assertThat(sut.bodyFont, nilValue())
        assertThat(sut.font, nilValue())
        assertThat(sut.emphasisFont, nilValue())
        assertThat(sut.secondaryFont, nilValue())
        assertThat(sut.mediumFontPointSize, equalTo(14))
        assertThat(sut.largeFontPointSize, equalTo(22))
    }

    func testDefaultSandThemeFactoryMethodShouldReturnACorrectlyConfiguredObject() {
        let sut = AppTheme.defaultSandTheme()

        assertThat(sut.appearance, equalTo(.sand))
        assertThat(sut.accentColor.toUIColor(), equalTo(UIColor(r: 97, g: 166, b: 171)))
        assertThat(sut.primaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 242, g: 230, b: 202)))
        assertThat(sut.secondaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 255, g: 248, b: 237)))
        assertThat(sut.tertiaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 255, g: 255, b: 255)))
        assertThat(sut.barTintColor?.toUIColor(), presentAnd(equalTo(UIColor(r: 193, g: 179, b: 152))))
        assertThat(sut.barTranslucent, isTrue())
        assertThat(sut.barStyle, equalTo(.default))
        assertThat(sut.navBarTitleFont, nilValue())
        assertThat(sut.barItemFont, nilValue())
        assertThat(sut.bodyFont, nilValue())
        assertThat(sut.font, nilValue())
        assertThat(sut.emphasisFont, nilValue())
        assertThat(sut.secondaryFont, nilValue())
        assertThat(sut.mediumFontPointSize, equalTo(14))
        assertThat(sut.largeFontPointSize, equalTo(22))
    }

    func testDefaultCustomThemeFactoryMethodShouldReturnACorrectlyConfiguredObject() {
        let sut = AppTheme.defaultCustomTheme()

        assertThat(sut.appearance, equalTo(.custom))
        assertThat(sut.accentColor.toUIColor(), equalTo(UIColor(rgb: 0xD80D30)))
        assertThat(sut.primaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 255, g: 255, b: 255)))
        assertThat(sut.secondaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 242, g: 242, b: 242)))
        assertThat(sut.tertiaryBackgroundColor.toUIColor(), equalTo(UIColor(r: 255, g: 227, b: 236)))
        assertThat(sut.barTintColor, nilValue())
        assertThat(sut.barTranslucent, isTrue())
        assertThat(sut.barStyle, equalTo(.default))
        assertThat(sut.navBarTitleFont, nilValue())
        assertThat(sut.barItemFont, nilValue())
        assertThat(sut.bodyFont, nilValue())
        assertThat(sut.font, nilValue())
        assertThat(sut.emphasisFont, nilValue())
        assertThat(sut.secondaryFont, nilValue())
        assertThat(sut.mediumFontPointSize, equalTo(14))
        assertThat(sut.largeFontPointSize, equalTo(22))
    }

}
#endif
