// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class CircleMaskedImageViewUITests: SnapshotTestCase {

    func testDisplaysSquareImageRoundedInACircle() {
        let sut = makeSUT(image: UIImage(named: "man_0.jpg"))
        let viewController = makeHost(centering: sut)

        verifySnapshot(viewController)
    }

    // MARK: Helpers

    private func makeSUT(image: UIImage?) -> CircleMaskedImageView {
        let sut = CircleMaskedImageView(image: image)
        sut.backgroundColor = UIColor.white
        return sut
    }

    private func makeHost(centering imageView: CircleMaskedImageView) -> UIViewController {
        let viewController = UIViewController(nibName: nil, bundle: nil)
        viewController.view.backgroundColor = UIColor.black
        viewController.view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor) ,
            imageView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        return viewController
    }
}
