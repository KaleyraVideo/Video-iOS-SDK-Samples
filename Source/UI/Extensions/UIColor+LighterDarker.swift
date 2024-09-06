// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit

extension UIColor {

    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        make(componentDelta: componentDelta)
    }

    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        make(componentDelta: -componentDelta)
    }

    var isLight: Bool {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        let components = getRGBAComponents()
        let redModifier: CGFloat = 299
        let greenModifier: CGFloat = 587
        let blueModifier: CGFloat = 114

        let brightness = ((components.red * redModifier) + (components.green * greenModifier) + (components.blue * blueModifier)) / 1000
        return brightness >= 0.5
    }

    internal func make(componentDelta: CGFloat) -> UIColor {
        let components = getRGBAComponents()

        return UIColor(
            red: add(componentDelta, toComponent: components.red),
            green: add(componentDelta, toComponent: components.green),
            blue: add(componentDelta, toComponent: components.blue),
            alpha: components.alpha
        )
    }

    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        (0.0...1.0).clamping(toComponent + value)
    }

    private func getRGBAComponents() -> ColorComponents {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return ColorComponents(red: red, green: green, blue: blue, alpha: alpha)
    }

    private struct ColorComponents {
        var red: CGFloat
        var green : CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }
}

extension ClosedRange where Bound: Comparable {

    func clamping(_ value: Bound) -> Bound {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}
