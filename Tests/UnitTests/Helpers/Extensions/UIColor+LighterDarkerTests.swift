// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class UIColor_LighterDarkerTests: UnitTestCase {

    private let comparisonPrecision: CGFloat = 0.00000001

    func testMakeFunctionShouldAddComponentDeltaToRGBValues() {
        let sut = UIColor.gray
        let addedColor = sut.make(componentDelta: 0.1)

        let rDelta = addedColor.rgba!.r - sut.rgba!.r
        let gDelta = addedColor.rgba!.g - sut.rgba!.g
        let bDelta = addedColor.rgba!.b - sut.rgba!.b
        let rCondition = (rDelta - 0.1) < comparisonPrecision
        let gCondition = (gDelta - 0.1) < comparisonPrecision
        let bCondition = (bDelta - 0.1) < comparisonPrecision
        let aCondition = addedColor.rgba!.a == 1

        assertThat(rCondition, isTrue())
        assertThat(gCondition, isTrue())
        assertThat(bCondition, isTrue())
        assertThat(aCondition, isTrue())
    }

    func testMakeFunctionShouldSubtractComponentDeltaToRGBValuesIfNegative() {
        let sut = UIColor.gray
        let addedColor = sut.make(componentDelta: -0.1)

        let rDelta = addedColor.rgba!.r - sut.rgba!.r
        let gDelta = addedColor.rgba!.g - sut.rgba!.g
        let bDelta = addedColor.rgba!.b - sut.rgba!.b
        let rCondition = (rDelta + 0.1) < comparisonPrecision
        let gCondition = (gDelta + 0.1) < comparisonPrecision
        let bCondition = (bDelta + 0.1) < comparisonPrecision
        let aCondition = addedColor.rgba!.a == 1

        assertThat(rCondition, isTrue())
        assertThat(gCondition, isTrue())
        assertThat(bCondition, isTrue())
        assertThat(aCondition, isTrue())
    }

    func testComponentDeltaAboveOneShouldClampRGBValuesToOne() {
        let sut = UIColor.gray
        let addedColor = sut.make(componentDelta: 1.5)

        let rCondition = addedColor.rgba!.r == 1
        let gCondition = addedColor.rgba!.g == 1
        let bCondition = addedColor.rgba!.b == 1
        let aCondition = addedColor.rgba!.a == 1

        assertThat(rCondition, isTrue())
        assertThat(gCondition, isTrue())
        assertThat(bCondition, isTrue())
        assertThat(aCondition, isTrue())
    }

    func testComponentDeltaNegativeGreatherThanRGBShouldClampRGBValuesToZero() {
        let sut = UIColor.gray
        let addedColor = sut.make(componentDelta: -1.5)

        let rCondition = addedColor.rgba!.r == 0
        let gCondition = addedColor.rgba!.g == 0
        let bCondition = addedColor.rgba!.b == 0
        let aCondition = addedColor.rgba!.a == 1

        assertThat(rCondition, isTrue())
        assertThat(gCondition, isTrue())
        assertThat(bCondition, isTrue())
        assertThat(aCondition, isTrue())
    }

    func testIsLightShouldReturnTrueIfTheColorIsLight() {
        let sut = UIColor.white

        assertThat(sut.isLight, isTrue())
    }

    func testIsLightShouldReturnFalseIfTheColorIsDark() {
        let sut = UIColor.black

        assertThat(sut.isLight, isFalse())
    }
}
