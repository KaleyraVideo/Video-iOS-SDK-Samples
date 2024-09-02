// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

#if SAMPLE_CUSTOMIZABLE_THEME
protocol Themable {
    func themeChanged(theme: AppTheme)
}

protocol CustomThemeFlowDelegateProtocol: ThemeChangedNotifier {
    func presentFont(onFontPicked: @escaping (UIFont) -> Void)
    func presentNumber(onNumberPicked: @escaping (CGFloat) -> Void)
    func presentBool(propertyName: String, onBoolPicked: @escaping (Bool) -> Void)
    func presentColor(selectedColor: UIColor, onColorPicked: @escaping (UIColor) -> Void)
    func presentBarStyle(propertyName: String, onBarSytlePicked: @escaping (UIBarStyle) -> Void)
    func presentKeyboardAppearance(propertyName: String, onKeyboardAppearanceTapped: @escaping (UIKeyboardAppearance) -> Void)
}

protocol CustomThemeViewModelProtocol {
    var selectedTheme: AppTheme { get }
    var dataSource: [CustomThemeModel] { get }
    var flowDelegate : CustomThemeFlowDelegateProtocol? { get }

    func handleSelection(of model: CustomThemeModel)
}

class CustomThemeViewModel: CustomThemeViewModelProtocol {

    var dataSource: [CustomThemeModel] = []

    var selectedTheme: AppTheme

    var flowDelegate: CustomThemeFlowDelegateProtocol?

    let themeStorage: ThemeStorage

    init(selectedTheme: AppTheme, themeStorage: ThemeStorage) {
        self.selectedTheme = selectedTheme
        self.themeStorage = themeStorage
        setUpDataSource()
    }

    private func setUpDataSource() {
        let mirror = Mirror(reflecting: selectedTheme)
        mirror.children.forEach { child in
            guard let label = child.label, let property = AppThemeProperty(rawValue: label) else { return }
            let childModel = CustomThemeModel(referenceProperty: property, value: child.value)

            childModel.valueChanged.append { [weak self] newVal in
                self?.selectedTheme.setValue(newVal, forKey: label)
                if self != nil {
                    self?.themeStorage.save(theme: self!.selectedTheme)
                    self?.flowDelegate?.notifyThemeChanged()
                }
            }
            dataSource.append(childModel)
        }
    }

    func handleSelection(of model: CustomThemeModel) {
        switch model.type {
            case .color:
                editColor(for: model)
            case .barStyle:
                editBarStyle(for: model)
            case .bool:
                editBoolean(for: model)
            case .keyboardAppearance:
                editKeyboardAppearance(for: model)
            case .font:
                editFont(for: model)
            case .number:
                editNumber(for: model)
        }
    }

    private func editColor(for model: CustomThemeModel) {
        let appThemeColor = model.value as? AppThemeColor ?? AppThemeColor()
        flowDelegate?.presentColor(selectedColor: appThemeColor.toUIColor(), onColorPicked: { colorPicked in
            appThemeColor.setValues(from: colorPicked)
            model.value = appThemeColor
        })
    }

    private func editFont(for model: CustomThemeModel) {
        let appThemeFont = model.value as? AppThemeFont ?? AppThemeFont()
        flowDelegate?.presentFont(onFontPicked: { fontPicked in
            appThemeFont.setValues(from: fontPicked)
            model.value = appThemeFont
        })
    }

    private func editNumber(for model: CustomThemeModel) {
        var appThemeNumber = model.value as? CGFloat ?? 0
        flowDelegate?.presentNumber(onNumberPicked: { number in
            appThemeNumber = number
            model.value = appThemeNumber
        })
    }

    private func editBarStyle(for model: CustomThemeModel) {
        var appThemeBarStyle = model.value as? UIBarStyle ?? UIBarStyle.default
        flowDelegate?.presentBarStyle(propertyName: model.name, onBarSytlePicked: { barStylePicked in
            appThemeBarStyle = barStylePicked
            model.value = appThemeBarStyle
        })
    }

    private func editBoolean(for model: CustomThemeModel) {
        var appThemeBool = model.value as? Bool ?? false
        flowDelegate?.presentBool(propertyName: model.name, onBoolPicked: { boolPicked in
            appThemeBool = boolPicked
            model.value = appThemeBool
        })
    }

    private func editKeyboardAppearance(for model: CustomThemeModel) {
        var appThemeKeyboardAppearance = model.value as? UIKeyboardAppearance ?? UIKeyboardAppearance.default
        flowDelegate?.presentKeyboardAppearance(propertyName: model.name, onKeyboardAppearanceTapped: { keyboardAppearancePicked in
            appThemeKeyboardAppearance = keyboardAppearancePicked
            model.value = appThemeKeyboardAppearance
        })
    }
}
#endif

enum AppThemeProperty: String {
    case accentColor
    case primaryBackgroundColor
    case secondaryBackgroundColor
    case tertiaryBackgroundColor
    case barTintColor
    case keyboardAppearance
    case barTranslucent
    case barStyle
    case navBarTitleFont
    case barItemFont
    case bodyFont
    case font
    case emphasisFont
    case secondaryFont
    case mediumFontPointSize
    case largeFontPointSize

    func getRelatedType() -> ThemeCustomCellCase {
        switch self {
        case .accentColor, .primaryBackgroundColor, .secondaryBackgroundColor, .tertiaryBackgroundColor, .barTintColor:
            return .color
        case .keyboardAppearance:
            return .keyboardAppearance
        case .barStyle:
            return .barStyle
        case .navBarTitleFont, .barItemFont, .bodyFont, .font, .emphasisFont, .secondaryFont:
            return .font
        case .mediumFontPointSize, .largeFontPointSize:
            return .number
        case .barTranslucent:
            return .bool
        }
    }
}


