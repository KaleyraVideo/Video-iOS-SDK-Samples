// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class ColorPreviewViewUITests: SnapshotTestCase {

    func testDisplayRoundedColorWithBorder() {
        let sut = makeSUT()
        sut.borderWidth = 4
        sut.borderColor = .red
        sut.backgroundColor = .blue

        let host = makeHost(sut)

        verifySnapshot(host)
    }

    func testDisplayRoundedColorWithoutBorder() {
        let sut = makeSUT()
        sut.backgroundColor = .blue

        let host = makeHost(sut)

        verifySnapshot(host)
    }

    // MARK: - Helpers

    private func makeSUT() -> ColorPreviewView {
        ColorPreviewView()
    }

    private func makeHost(_ view: UIView, size: CGSize = CGSize(width: 40, height: 40)) -> UIViewController {
        let host = UIViewController()
        host.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: host.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: host.view.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: size.width),
            view.heightAnchor.constraint(equalToConstant: size.height),
        ])
        return host
    }

}

