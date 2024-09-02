// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import SwiftHamcrest
import CoreText
import KaleyraTestKit
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME
final class CustomThemeViewModelTests: UnitTestCase {

    func testShouldHaveDataSourceNotEmpty() {
        let sut = makeSUT()

        assertThat(sut.dataSource.count, presentAnd(equalTo(16)))
    }

    func testMethodsShouldCallFlowDelegateMethods() {
        let sut = makeSUT()
        let spy = CustomThemeFlowDelegateSpy()

        sut.flowDelegate = spy
        sut.handleSelection(of: CustomThemeModel(referenceProperty: .font, value: UIFont.systemFont(ofSize: 18)))
        sut.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.keyboardAppearance, value: UIKeyboardAppearance.default))
        sut.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.barTranslucent, value: false))
        sut.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.mediumFontPointSize, value: 10))
        sut.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.mediumFontPointSize, value: 10))
        sut.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.barStyle, value: UIBarStyle.black))
        sut.handleSelection(of: CustomThemeModel(referenceProperty: .accentColor, value: UIColor.green))

        assertThat(spy.fontPresented, isTrue())
        assertThat(spy.colorPresented, isTrue())
        assertThat(spy.boolPresented, isTrue())
        assertThat(spy.barStylePresented, isTrue())
        assertThat(spy.numberPresented, isTrue())
        assertThat(spy.keyboardAppearancePresented, isTrue())
    }

    func testThemeStorageShouldSaveAppThemeWheneverCellValueChanges() {
        let spy = ThemeStorageSpy()
        let sut = makeSUT(themeStorage: spy)

        sut.dataSource.first?.value = "test"

        assertThat(spy.themeSaved, present())
    }

    func testFlowDelegateNotifyThemeChangedShouldBeCalledWheneverTheValueOfAPropertyOfTheDatasourceHasBeenUpdated() {
        let sut = makeSUT()
        let spy = CustomThemeFlowDelegateSpy()

        sut.flowDelegate = spy
        sut.dataSource.first?.value = "test"

        assertThat(spy.notifyThemeChangedInvocation, hasCount(1))
    }

    // MARK: - Helpers

    private func makeSUT(themeStorage: ThemeStorage = ThemeStorageSpy()) -> CustomThemeViewModel {
        CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: themeStorage)
    }
}

class CustomThemeFlowDelegateSpy: CustomThemeFlowDelegateProtocol {

    var fontPresented: Bool = false
    var colorPresented: Bool = false
    var boolPresented: Bool = false
    var barStylePresented: Bool = false
    var numberPresented: Bool = false
    var keyboardAppearancePresented = false
    var notifyThemeChangedInvocation: [()] = []

    func presentFont(onFontPicked: @escaping (UIFont) -> Void) {
        fontPresented = true
    }

    func presentColor(selectedColor: UIColor, onColorPicked: @escaping (UIColor) -> Void) {
        colorPresented = true
    }

    func presentNumber(onNumberPicked: @escaping (CGFloat) -> Void) {
        numberPresented = true
    }

    func presentBool(propertyName: String, onBoolPicked: @escaping (Bool) -> Void) {
        boolPresented = true
    }

    func presentBarStyle(propertyName: String, onBarSytlePicked: @escaping (UIBarStyle) -> Void) {
        barStylePresented = true
    }

    func presentKeyboardAppearance(propertyName: String, onKeyboardAppearanceTapped: @escaping (UIKeyboardAppearance) -> Void) {
        keyboardAppearancePresented = true
    }

    func notifyThemeChanged() {
        notifyThemeChangedInvocation.append(())
    }
}
#endif
