// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME

final class CustomThemeViewControllerTests: UnitTestCase {

    func testSUTInitializedWithTheRightUIElements() {
        let sut = CustomThemeViewController()

        sut.loadViewIfNeeded()

        assertThat(sut.view.backgroundColor, equalTo(.white))
        assertThat(sut.navigationItem.title, equalTo(NSLocalizedString("settings.custom.theme", comment: "custom theme")))
        assertThat(sut.tableView, present())
        assertThat(sut.tableView.isDescendant(of: sut.view), isTrue())
    }

    func testSUTnumberOfRowsInSectionShouldReturn() {
        let sut = CustomThemeViewController()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        sut.viewModel = viewModel
        sut.loadViewIfNeeded()

        assertThat(sut.tableView(sut.tableView, numberOfRowsInSection: 0), equalTo(viewModel.dataSource.count))
    }

    func testSUTheightForRowAtReturns70() {
        let sut = CustomThemeViewController()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        sut.viewModel = viewModel
        sut.loadViewIfNeeded()

        assertThat(sut.tableView(sut.tableView, heightForRowAt: IndexPath(item: 0, section: 0)), equalTo(70))
    }

    func testSUTTableViewShouldBeSettedUpCorrectly() {
        let sut = CustomThemeViewController()

        sut.loadViewIfNeeded()

        assertThat(sut.tableView.delegate, presentAnd(instanceOf(CustomThemeViewController.self)))
        assertThat(sut.tableView.dataSource, presentAnd(instanceOf(CustomThemeViewController.self)))
        assertThat(sut.tableView.translatesAutoresizingMaskIntoConstraints, equalTo(false))
    }

    func testSUTColorCalledShouldInvokeDelegateMethod() {
        let sut = CustomThemeViewController()
        let spy = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        viewModel.flowDelegate = spy
        sut.viewModel = viewModel
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.accentColor, value: UIColor.black))

        assertThat(spy.colorPresented, equalTo(true))
    }

    func testSUTBarStyleCalledShouldInvokeDelegateMethod() {
        let sut = CustomThemeViewController()
        let spy = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        sut.viewModel = viewModel
        viewModel.flowDelegate = spy
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.barStyle, value: UIBarStyle.black))

        assertThat(spy.barStylePresented, equalTo(true))
    }

    func testSUTBoolStyleCalledShouldInvokeDelegateMethod() {
        let sut = CustomThemeViewController()
        let spy = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        viewModel.flowDelegate = spy
        sut.viewModel = viewModel
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: .barTranslucent, value: true))

        assertThat(spy.boolPresented, equalTo(true))
    }

    func testSUTKeyboardAppearanceCalledShouldInvokeDelegateMethod() {
        let sut = CustomThemeViewController()
        let spy = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        viewModel.flowDelegate = spy
        sut.viewModel = viewModel
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.keyboardAppearance, value: UIKeyboardAppearance.dark))

        assertThat(spy.keyboardAppearancePresented, equalTo(true))
    }

    func testSUTFontCalledShouldInvokeDelegateMethod() {
        let sut = CustomThemeViewController()
        let spy = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        sut.viewModel = viewModel
        viewModel.flowDelegate = spy
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.font, value: AppThemeFont()))

        assertThat(spy.fontPresented, equalTo(true))
    }

    func testSUTNumberCalledShouldInvokeDelegateMethod() {
        let sut = CustomThemeViewController()
        let spy = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())

        viewModel.flowDelegate = spy
        sut.viewModel = viewModel
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.mediumFontPointSize, value: 10))

        assertThat(spy.numberPresented, equalTo(true))
    }

    func testSUTShouldCallCorrectDelegateMethodsWhenCellIsTapped() {
        let sut = CustomThemeViewController()
        let flowDelegate = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())
        viewModel.flowDelegate = flowDelegate
        sut.viewModel = viewModel

        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.font, value: AppThemeFont()))
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: .barTintColor, value: UIColor.red))
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.barTranslucent, value: false))
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.barStyle, value: UIBarStyle.default))
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.mediumFontPointSize, value: 10))
        sut.viewModel?.handleSelection(of: CustomThemeModel(referenceProperty: AppThemeProperty.keyboardAppearance, value: UIKeyboardAppearance.default))

        assertThat(flowDelegate.fontPresented, isTrue())
        assertThat(flowDelegate.barStylePresented, isTrue())
        assertThat(flowDelegate.colorPresented, isTrue())
        assertThat(flowDelegate.boolPresented, isTrue())
        assertThat(flowDelegate.numberPresented, isTrue())
    }

    func testTableViewShouldConfigureCellColorAccordingly() {
        let sut = CustomThemeViewController()
        let flowDelegate = CustomThemeFlowDelegateSpy()
        let viewModel = CustomThemeViewModel(selectedTheme: AppTheme(), themeStorage: DummyThemeStorage())
        viewModel.flowDelegate = flowDelegate
        sut.viewModel = viewModel

        sut.loadViewIfNeeded()

        for i in 0...viewModel.dataSource.count-1 {
            guard let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(item: i, section: 0)) as? ColorTableViewCell else { return }
            if let color = (sut.viewModel?.dataSource[i].value) as? AppThemeColor {

                assertThat(cell.color, presentAnd(instanceOf(UIColor.self)))
                assertThat(color.toUIColor(), equalTo(cell.color!))
            }
        }
    }

    func testThemeDelegateShouldSetViewControllerParametersCorrectly() {
        let sut = CustomThemeViewController()
        let appTheme = makeTheme()

        sut.themeChanged(theme: appTheme)

        assertThat(sut.view.backgroundColor, equalTo(appTheme.primaryBackgroundColor.toUIColor()))
        assertThat(sut.tableView.backgroundColor, equalTo(appTheme.secondaryBackgroundColor.toUIColor()))
        sut.view.subviews.forEach { subview in
            assertThat(appTheme.accentColor, present())
            assertThat(subview.tintColor, equalTo(appTheme.accentColor.toUIColor()))
        }
    }

    // MARK: - Helpers

    private func makeTheme() -> AppTheme {
        let appTheme = AppTheme()

        let primaryColor = AppThemeColor()
        primaryColor.setValues(from: .green)
        appTheme.primaryBackgroundColor = primaryColor

        let secondaryColor = AppThemeColor()
        secondaryColor.setValues(from: .systemPink)
        appTheme.secondaryBackgroundColor = secondaryColor

        let tertiaryColor = AppThemeColor()
        tertiaryColor.setValues(from: .systemPink)
        appTheme.tertiaryBackgroundColor = tertiaryColor

        let accentColor = AppThemeColor()
        accentColor.setValues(from: .blue)
        appTheme.accentColor = accentColor

        let keyboardAppearance = UIKeyboardAppearance.dark
        appTheme.keyboardAppearance = keyboardAppearance

        appTheme.barTranslucent = true

        appTheme.barStyle = .black

        let barTint = AppThemeColor()
        barTint.setValues(from: .systemPink)
        appTheme.barTintColor = barTint

        let font = UIFont(name: "avenir-black", size:  12)!
        let appFont = AppThemeFont()
        appFont.setValues(from: font)
        appTheme.navBarTitleFont = appFont

        appTheme.barItemFont = appFont

        appTheme.bodyFont = appFont

        appTheme.font = appFont

        appTheme.emphasisFont = appFont

        appTheme.secondaryFont = appFont

        appTheme.mediumFontPointSize = 20

        appTheme.largeFontPointSize = 25

        return appTheme
    }
}

class CustomThemeViewModelSpy: CustomThemeViewModelProtocol {

    var selectedTheme: AppTheme = AppTheme()

    func handleSelection(of model: CustomThemeModel) { }

    var flowDelegate: CustomThemeFlowDelegateProtocol?

    var dataSource = [CustomThemeModel]()
}

#endif
