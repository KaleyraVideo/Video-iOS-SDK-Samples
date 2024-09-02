// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

class CustomThemeModel {
    var name : String {
        referenceProperty.rawValue
    }

    var value: Any {
        didSet {
            valueChanged.forEach { callback in
                callback(value)
            }
        }
    }

    var referenceProperty: AppThemeProperty
    var valueChanged: [((Any) -> Void)] = []

    var type: ThemeCustomCellCase {
        referenceProperty.getRelatedType()
    }

    init(referenceProperty: AppThemeProperty, value: Any) {
        self.referenceProperty = referenceProperty
        self.value = value
    }
}
