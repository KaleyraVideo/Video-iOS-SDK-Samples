// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class RoundedButtonUITests: SnapshotTestCase {

    func testAppearanceOfRoundedButton() {
        let sut = RoundedButton()
        sut.setTitle("Test", for: .normal)

        let vc = UIViewController()
        vc.loadViewIfNeeded()

        vc.view.addSubview(sut)
        vc.view.backgroundColor = .white
        sut.center = vc.view.center
        verifySnapshot(vc)
    }
}
