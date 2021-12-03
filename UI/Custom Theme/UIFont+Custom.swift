//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE for licensing information.
//

import UIKit

extension UIFont {

    static var robotoMedium: UIFont {
        guard let font = UIFont(name: "Roboto-Medium", size: 20) else {
            fatalError("No font found with Roboto-Medium name")
        }

        return font
    }

    static var robotoLight: UIFont {
        guard let font = UIFont(name: "Roboto-Light", size: 11) else {
            fatalError("No font found with Roboto-Light name")
        }

        return font
    }
    
    static var robotoThin: UIFont {
        guard let font = UIFont(name: "Roboto-Thin", size: 17) else {
            fatalError("No font found with Roboto-Thin name")
        }

        return font
    }
    
    static var robotoRegular: UIFont {
        guard let font = UIFont(name: "Roboto-Regular", size: 17) else {
            fatalError("No font found with Roboto-Regular name")
        }

        return font
    }
    
    static var robotoBold: UIFont {
        guard let font = UIFont(name: "Roboto-Bold", size: 17) else {
            fatalError("No font found with Roboto-Bold name")
        }

        return font
    }
}
