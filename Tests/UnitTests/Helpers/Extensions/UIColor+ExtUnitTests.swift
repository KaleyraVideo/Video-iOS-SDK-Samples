// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class UIColor_ExtUnitTests: UnitTestCase {

    func testInitRGBShouldCreateUIColorWithExpectedComponents() {
        let sut = UIColor(r: 0xD8, g: 0x0D, b: 0x30)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        sut.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        assertThat(Double(red), closeTo(0.8470588235, 0.00001))
        assertThat(Double(green), closeTo(0.05098039216, 0.00001))
        assertThat(Double(blue), closeTo(0.1882352941, 0.00001))
        assertThat(Double(alpha), closeTo(1.0, 0.00001))
    }

    func testInitRGBAShouldCreateColorWithExpectedComponents() {
        let sut = UIColor(rgb: 0xD80D30)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        sut.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        assertThat(Double(red), closeTo(0.8470588235, 0.00001))
        assertThat(Double(green), closeTo(0.05098039216, 0.00001))
        assertThat(Double(blue), closeTo(0.1882352941, 0.00001))
        assertThat(Double(alpha), closeTo(1.0, 0.00001))
    }
}
