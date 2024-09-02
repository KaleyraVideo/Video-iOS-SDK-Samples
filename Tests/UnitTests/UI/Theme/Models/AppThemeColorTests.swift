// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class AppThemeColorTests: UnitTestCase {

    func testSetValuesFromUIColorShouldSetColorComponentsValueToRespectiveProperties() {
        let sut = AppThemeColor()
        let color = UIColor.brown.withAlphaComponent(0.8)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        sut.setValues(from: color)

        assertThat(sut.red, equalTo(red))
        assertThat(sut.green, equalTo(green))
        assertThat(sut.blue, equalTo(blue))
        assertThat(sut.alpha, equalTo(alpha))
    }

    func testToUIColorShouldReturnTheCorrectUIColor() {
        let sut = AppThemeColor()
        let color = UIColor.brown.withAlphaComponent(0.5)

        sut.setValues(from: color)

        assertThat(sut.toUIColor(), equalTo(color))
    }

    func testInitFromColorShouldSetColorComponentsValueToRespectiveProperties() {
        let color = UIColor.brown.withAlphaComponent(0.8)
        let sut = AppThemeColor(from: color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        assertThat(sut.red, equalTo(red))
        assertThat(sut.green, equalTo(green))
        assertThat(sut.blue, equalTo(blue))
        assertThat(sut.alpha, equalTo(alpha))
    }
}
