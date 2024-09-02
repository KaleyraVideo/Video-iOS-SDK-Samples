// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME
final class ThemeCoordinatorTests: UnitTestCase {

    func testThemeCoordinatorIsInstantiatedWithNavigationController() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)

        assertThat(sut.navigationController, present())
    }

    func testThemeCoordinatorIsInstantiatedWithThemeStorage() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)

        assertThat(sut.themeStorage, present())
    }

    func testThatChildrenArrayIsEmptyWhenInitialized() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)

        assertThat(sut.getChildren().count, equalTo(0))
    }

    func testThemeCoordinatorSetUpCorrectly() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)

        sut.start()

        assertThat(sut.navigationController.viewControllers.count, equalTo(1))
    }

    func testCustomThemeShouldPushCustomThemeViewControllerInNavigationStack() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)

        sut.pushCustomThemeViewController(with: AppTheme())

        assertThat(sut.navigationController.viewControllers, hasCount(1))
        assertThat(sut.navigationController.viewControllers.last as? CustomThemeViewController, present())
    }

    func testCustomThemeViewControllerShouldBeInitializedWithPickerFactory() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)

        sut.pushCustomThemeViewController(with: AppTheme())

        guard let customVC = sut.navigationController.viewControllers.last as? CustomThemeViewController else { return }

        assertThat(customVC.pickerFactory, present())
    }

    func testThemeCoordinatorShouldCallDelegateMethodsWithCorrectParameters() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)
        let pickerFactorySpy = PickerFactorySpy()

        sut.pickerFactory = pickerFactorySpy
        let _ = sut.pickerFactory?.createColorPicker(selectedColor: .black, onColorPicked: { _ in })
        let _ = sut.pickerFactory?.createNumberPicker(onNumber: { _ in })
        let _ = sut.pickerFactory?.createOptionPicker(title: "prova", options: [UIAlertAction(title: "", style: .default, handler: { _ in })], onOptionPicked: { _ in })
        let _ = sut.pickerFactory?.createFontPicker(onFontPicked: { _ in })

        assertThat(pickerFactorySpy.selectedColor, presentAnd(equalTo(.black)))

        assertThat(pickerFactorySpy.title, presentAnd(equalTo("prova")))
        assertThat(pickerFactorySpy.options, presentAnd(isTrue()))
        assertThat(pickerFactorySpy.onOptionPicked, presentAnd(isTrue()))

        assertThat(pickerFactorySpy.onNumber, present())

        assertThat(pickerFactorySpy.onFontPicked, present())
    }

    func testNotifyThemeChangedShouldPropagateAThemeChangedEventToItsParent() {
        let nav = UINavigationController()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeCoordinator(navigationController: nav, themeStorage: themeStorage)
        let parent = ChainCoordinatorSpy()

        sut.parent = parent
        sut.notifyThemeChanged()

        assertThat(parent.handleCallsWithParams, hasCount(1))
        assertThat(parent.handleCallsWithParams.first?.0, presentAnd(equalTo(.refreshTheme)))
        assertThat(parent.handleCallsWithParams.first?.1, nilValue())
        assertThat(parent.handleCallsWithParams.first?.2, presentAnd(equalTo(.toParent)))
    }
}

class PickerFactorySpy: NSObject, ColorPickerFactory, FontPickerFactory, OptionsPickerFactory, NumberPickerFactory {

    var selectedColor: UIColor?
    var onColorPicked: ((UIColor) -> Void)?

    var onFontPicked: ((UIFont) -> Void)?

    var title: String = ""
    var options: Bool = false
    var onOptionPicked: Bool = false

    var onNumber: ((CGFloat) -> Void)?

    func createColorPicker(selectedColor: UIColor, onColorPicked: @escaping ((UIColor) -> Void)) -> UIViewController {
        self.selectedColor = selectedColor
        self.onColorPicked = onColorPicked
        return UIViewController()
    }

    func createFontPicker(onFontPicked: @escaping ((UIFont) -> Void)) -> UIViewController {
        self.onFontPicked = onFontPicked
        return UIViewController()
    }

    func createOptionPicker<T>(title: String, options: [T], onOptionPicked: @escaping ((T) -> Void)) -> UIViewController where T : CustomStringConvertible {
        self.title = title
        self.options = true
        self.onOptionPicked = true
        return UIViewController()
    }

    func createNumberPicker(onNumber: @escaping ((CGFloat) -> Void)) -> UIViewController {
        self.onNumber = onNumber
        return UIViewController()
    }
}

#endif
