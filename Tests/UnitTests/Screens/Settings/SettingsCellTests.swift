// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class SettingsCellTests: UnitTestCase {

    private var sut: SettingsCell!

    override func setUp() {
        super.setUp()

        sut = .init(style: .default, reuseIdentifier: nil)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitShouldSetupBackgroundView() {
        assertThat(sut.selectedBackgroundView, present())
        assertThat(sut.selectedBackgroundView?.backgroundColor, presentAnd(equalTo(.lightGray)))
    }

    func testInitShouldSetupLabelsCorrectly() {
        assertThat(sut.textLabel?.font, presentAnd(equalTo(.systemFont(ofSize: 18))))
    }

    func testChangeTheCellStyleToDangerShouldChangeTextLabelTextColorToRed() {
        sut.cellStyle = .danger

        assertThat(sut.textLabel?.textColor, presentAnd(equalTo(.red)))
    }
}
