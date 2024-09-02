// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class CustomThemeModelTests: UnitTestCase {

    func testShouldInitializeReferenceParameters() {
        let sut = CustomThemeModel(referenceProperty: .accentColor, value: UIColor.black)

        assertThat(sut.referenceProperty, equalTo(AppThemeProperty.accentColor))
        assertThat(sut.value as! UIColor, equalTo(UIColor.black as UIColor))
    }

    func testNameShouldBeInitializedWithReferencePropertyRawValue() {
        let sut = CustomThemeModel(referenceProperty: .font, value: UIFont(name: "avenir-black", size: 20)!)

        assertThat(sut.name, equalTo("font"))
    }

    func testTypeShouldGetRespectiveTypeFromEnumReferenceTypeColor() {
        let sut = CustomThemeModel(referenceProperty: .accentColor, value: UIColor.black)

        assertThat(sut.type, equalTo(.color))
    }

    func testTypeShouldGetRespectiveTypeFromEnumReferenceTypeBool() {
        let sut = CustomThemeModel(referenceProperty: .barTranslucent, value: true)

        assertThat(sut.type, equalTo(.bool))
    }

    func testTypeShouldGetRespectiveTypeFromEnumReferenceTypeBarStyle() {
        let sut = CustomThemeModel(referenceProperty: .barStyle, value: UIColor.black)

        assertThat(sut.type, equalTo(.barStyle))
    }

    func testTypeShouldGetRespectiveTypeFromEnumReferenceTypeFont() {
        let sut = CustomThemeModel(referenceProperty: .font, value: UIColor.black)

        assertThat(sut.type, equalTo(.font))
    }

    func testTypeShouldGetRespectiveTypeFromEnumReferenceTypeKeyboardAppearance() {
        let sut = CustomThemeModel(referenceProperty: .keyboardAppearance, value: UIColor.black)

        assertThat(sut.type, equalTo(.keyboardAppearance))
    }

    func testTypeShouldGetRespectiveTypeFromEnumReferenceTypeNumber() {
        let sut = CustomThemeModel(referenceProperty: .largeFontPointSize, value: UIColor.black)

        assertThat(sut.type, equalTo(.number))
    }

    func testValueMultiplySetShouldAppenMultipleInvocationsOnValueChanged() {
        let sut = CustomThemeModel(referenceProperty: .mediumFontPointSize, value: 20)

        var invocations: [Any] = []
        sut.valueChanged.append { value in
            invocations.append(value)
        }

        sut.valueChanged.append { value in
            invocations.append(value)
        }

        sut.value = "Test"

        assertThat(invocations.count, equalTo(2))
        invocations.forEach { invocation in
            assertThat(invocation, instanceOf(String.self))
            assertThat(invocation as! String, equalTo("Test"))
        }
    }
}
