// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

#if SAMPLE_CUSTOMIZABLE_THEME
class ThemeCoordinator: BaseCoordinator {

    var pickerFactory: (ColorPickerFactory & FontPickerFactory & OptionsPickerFactory & NumberPickerFactory)?
    var navigationController: UINavigationController

    init(navigationController: UINavigationController, themeStorage: ThemeStorage) {
        self.navigationController = navigationController
        super.init(themeStorage: themeStorage)
    }

    func start() {
        let themeVC = ThemeViewController(theme: themeStorage.getSelectedTheme())
        let viewModel = ThemeViewModel(themeStorage: themeStorage)
        viewModel.flowDelegate = self
        themeVC.viewModel = viewModel
        navigationController.pushViewController(themeVC, animated: true)
    }
}

extension ThemeCoordinator: ThemeChangedNotifier {

    func notifyThemeChanged() {
        try? handle(event: .refreshTheme, additionalInfo: nil, eventDirection: .toParent)
    }
}

extension ThemeCoordinator: ThemeFlowDelegate {

    func pushCustomThemeViewController(with theme: AppTheme) {
        let pickerFactory = PickerFactory()
        let viewModel = CustomThemeViewModel(selectedTheme: theme, themeStorage: themeStorage)
        viewModel.flowDelegate = self

        let customViewController = CustomThemeViewController()
        customViewController.pickerFactory = pickerFactory
        customViewController.viewModel = viewModel
        navigationController.pushViewController(customViewController, animated: true)
    }
}

extension ThemeCoordinator: CustomThemeFlowDelegateProtocol {

    func presentColor(selectedColor: UIColor, onColorPicked: @escaping (UIColor) -> Void) {
        guard let picker = pickerFactory?.createColorPicker(selectedColor: selectedColor, onColorPicked: onColorPicked) else { return }
        navigationController.present(picker, animated: true)
    }

    func presentFont(onFontPicked: @escaping (UIFont) -> Void) {
        guard let picker = pickerFactory?.createFontPicker(onFontPicked: onFontPicked) else { return }
        navigationController.present(picker, animated: true)
    }

    func presentNumber(onNumberPicked: @escaping (CGFloat) -> Void) {
        guard let picker = pickerFactory?.createNumberPicker(onNumber: onNumberPicked) else { return }
        navigationController.present(picker, animated: true)
    }

    func presentBool(propertyName: String, onBoolPicked: @escaping (Bool) -> Void) {
        guard let picker = pickerFactory?.createOptionPicker(title: propertyName, options: [true, false], onOptionPicked: onBoolPicked) else { return }
        navigationController.present(picker, animated: true)
    }

    func presentBarStyle(propertyName: String, onBarSytlePicked: @escaping (UIBarStyle) -> Void) {
        guard let picker = pickerFactory?.createOptionPicker(title: propertyName, options: [UIBarStyle.default, UIBarStyle.black], onOptionPicked: onBarSytlePicked) else { return }
        navigationController.present(picker, animated: true)
    }

    func presentKeyboardAppearance(propertyName: String, onKeyboardAppearanceTapped: @escaping (UIKeyboardAppearance) -> Void) {
        guard let picker = pickerFactory?.createOptionPicker(title: propertyName, options: [UIKeyboardAppearance.default, UIKeyboardAppearance.light, UIKeyboardAppearance.dark], onOptionPicked: onKeyboardAppearanceTapped) else { return }
        navigationController.present(picker, animated: true)
    }
}

extension UIKeyboardAppearance: CustomStringConvertible {
    public var description: String {
        switch self {
            case .default:
                return "default"
            case .dark:
                return "dark"
            case .light:
                return "light"
        }
    }
}

extension UIBarStyle: CustomStringConvertible {
    public var description: String {
        switch self {
            case .default:
                return "default"
            case .black:
                return "black"
            case .blackTranslucent:
                return "blackTranslucent"
        }
    }
}
#endif
