// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

#if SAMPLE_CUSTOMIZABLE_THEME
class AppTheme: NSObject, Codable{

    var id: UUID = UUID()

    var name: String {
        appearance.description
    }

    var appearance: ThemeAppearance = .light
    @objc var accentColor = AppThemeColor()
    @objc var primaryBackgroundColor = AppThemeColor()
    @objc var secondaryBackgroundColor = AppThemeColor()
    @objc var tertiaryBackgroundColor = AppThemeColor()
    @objc var barTintColor: AppThemeColor?
    @objc var keyboardAppearance: UIKeyboardAppearance = .default
    @objc var barTranslucent: Bool = true
    @objc var barStyle: UIBarStyle = .default
    @objc var navBarTitleFont: AppThemeFont?
    @objc var barItemFont: AppThemeFont?
    @objc var bodyFont: AppThemeFont?
    @objc var font: AppThemeFont?
    @objc var emphasisFont: AppThemeFont?
    @objc var secondaryFont: AppThemeFont?
    @objc var mediumFontPointSize: CGFloat = 14
    @objc var largeFontPointSize: CGFloat = 22

    @IgnoreCodableProperty var selectedChanged: ((Bool) -> Void)?
    var selected: Bool = false {
        didSet {
            selectedChanged?(selected)
        }
    }

    override init() {
        accentColor.setValues(from: Theme.Color.primary)
        primaryBackgroundColor.setValues(from: .white)
        secondaryBackgroundColor.setValues(from: .white)
        tertiaryBackgroundColor.setValues(from: .white)
    }

    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        lhs.id == rhs.id
    }

    func setValue<T: RawRepresentable>(_ value: T, forKey key: String) where T.RawValue == Int {
        super.setValue(NSNumber(value: value.rawValue), forKey: key)
    }

    override func setValue(_ value: Any?, forKey key: String) {
        if let barStyle = value as? UIBarStyle {
            setValue(barStyle, forKey: key)
        } else if let keyboardApp = value as? UIKeyboardAppearance {
            setValue(keyboardApp, forKey: key)
        } else {
            super.setValue(value, forKey: key)
        }
    }

    func toSdkTheme() -> Bandyer.Theme {
        let theme = Bandyer.Theme()
        theme.accentColor = self.accentColor.toUIColor()
        theme.primaryBackgroundColor = self.primaryBackgroundColor.toUIColor()
        theme.secondaryBackgroundColor = self.secondaryBackgroundColor.toUIColor()
        theme.tertiaryBackgroundColor = self.tertiaryBackgroundColor.toUIColor()
        theme.keyboardAppearance = self.keyboardAppearance
        theme.barTranslucent = self.barTranslucent
        theme.barStyle = self.barStyle
        theme.barTintColor = self.barTintColor?.toUIColor()
        theme.navBarTitleFont = self.navBarTitleFont?.toUIFont()
        theme.barItemFont = self.barItemFont?.toUIFont()
        theme.bodyFont = self.bodyFont?.toUIFont()
        theme.font = self.font?.toUIFont()
        theme.emphasisFont = self.emphasisFont?.toUIFont()
        theme.secondaryFont = self.secondaryFont?.toUIFont()
        theme.mediumFontPointSize = self.mediumFontPointSize
        theme.largeFontPointSize = self.largeFontPointSize
        return theme
    }

    static func defaultLightTheme() -> AppTheme {
        let lightTheme = AppTheme()
        lightTheme.appearance = .light
        lightTheme.primaryBackgroundColor.setValues(from: .white)
        lightTheme.secondaryBackgroundColor.setValues(from: UIColor(r: 242, g: 242, b: 242))
        lightTheme.tertiaryBackgroundColor.setValues(from: UIColor(r: 255, g: 227, b: 236))
        return lightTheme
    }

    static func defaultDarkTheme() -> AppTheme {
        let darkTheme = AppTheme()
        darkTheme.appearance = .dark
        darkTheme.primaryBackgroundColor.setValues(from: .black)
        darkTheme.secondaryBackgroundColor.setValues(from: UIColor(r: 28, g: 28, b: 28))
        darkTheme.tertiaryBackgroundColor.setValues(from: UIColor(r: 44, g: 44, b: 44))
        darkTheme.barTintColor = AppThemeColor(from: .black)
        return darkTheme
    }

    static func defaultSandTheme() -> AppTheme {
        let sandTheme = AppTheme()
        sandTheme.appearance = .sand
        sandTheme.accentColor.setValues(from: UIColor(r: 97, g: 166, b: 171)) // #61A6AB
        sandTheme.primaryBackgroundColor.setValues(from: UIColor(r: 242, g: 230, b: 202)) // #F2E6CA
        sandTheme.secondaryBackgroundColor.setValues(from: UIColor(r: 255, g: 248, b: 237)) // #FFF8ED
        sandTheme.tertiaryBackgroundColor.setValues(from: UIColor(r: 255, g: 255, b: 255)) // #FFFFFF
        sandTheme.barTintColor = AppThemeColor(from: UIColor(r: 193, g: 179, b: 152)) // #C1B398
        return sandTheme
    }

    static func defaultCustomTheme() -> AppTheme {
        let customTheme = AppTheme.defaultLightTheme()
        customTheme.appearance = .custom
        return customTheme
    }
}

enum ThemeAppearance : String, Codable, CustomStringConvertible {

    case light
    case dark
    case sand
    case custom

    var description: String {
        switch self {
            case .light:
                return Strings.Settings.lightMode
            case .dark:
                return Strings.Settings.darkMode
            case .sand:
                return Strings.Settings.sandMode
            case .custom:
                return Strings.Settings.customMode
        }
    }
}

extension UIBarStyle: Codable { }

extension UIKeyboardAppearance: Codable { }
#endif
