//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit

extension UIColor {

    static var accentColor: UIColor {
        let color: UIColor

        if #available(iOS 11.0, *) {
            if let accent = UIColor(named: "AccentColor") {
                color = accent
            } else {
                color = UIColor(red: 0, green: 107/255, blue: 128/255, alpha: 1)
            }
        } else {
            color = UIColor(red: 0, green: 107/255, blue: 128/255, alpha: 1)
        }

        return color
    }

    static var customBackground: UIColor {
        let color: UIColor

        if #available(iOS 13.0, *) {
            color = UIColor { collection in
                switch collection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0, green: 139/255, blue: 139/255, alpha: 1)
                default:
                    return UIColor(red: 175/255, green: 238/255, blue: 238/255, alpha: 1)
                }
            }
        } else {
            color = UIColor(red: 175/255, green: 238/255, blue: 238/255, alpha: 1)
        }

        return color
    }
    
    static var customSecondary: UIColor {
        let color: UIColor
        
        if #available(iOS 13.0, *) {
            color = UIColor { collection in
                switch collection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 60/255, green: 180/255, blue: 150/255, alpha: 1)
                default:
                    return UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1)
                }
            }
        } else {
            color = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1)
        }
        return color
    }

    static var customTertiary: UIColor {
        let color: UIColor

        if #available(iOS 13.0, *) {
            color = UIColor { collection in
                switch collection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 183/255, green: 180/255, blue: 186/255, alpha: 1)
                default:
                    return UIColor(red: 183/255, green: 194/255, blue: 183/255, alpha: 1)
                }
            }
        } else {
            color = UIColor(red: 183/255, green: 194/255, blue: 183/255, alpha: 1)
        }
        return color
    }

    static var customBarTintColor: UIColor {
        UIColor(red: 169/255, green: 146/255, blue: 166/255, alpha: 1)
    }
}
