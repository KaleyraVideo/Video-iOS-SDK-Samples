// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class LoaderViewUITests: SnapshotTestCase {

    func testAppearanceOfLoaderInView() {
        let vc = UIViewController()
        vc.loadViewIfNeeded()

        let sut = LoaderView(image: Icons.logo256)

        vc.view.addSubview(sut)

        NSLayoutConstraint.activate([
            sut.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            sut.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        ])

        vc.view.backgroundColor = .red

        verifySnapshot(vc)
    }
}
