// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class PlaceholderInfoViewUITests: SnapshotTestCase {

    func testPlaceholderErrorViewShouldShowErrorInformation() {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 700)
        let header = LoaderView(image: #imageLiteral(resourceName: "callkit-icon"))
        let sut = PlaceholderInfoView.placeholderError(frame: frame, title: "Title", subtitle: "Subtitle", header: header, actionTitle: "Retry") {}
        sut.backgroundColor = .red

        let host = makeHost(addingView: sut)

        verifySnapshot(host)
    }

    func testPlaceholderViewShouldShowLoadingInformation() {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 700)
        let header = LoaderView(image: #imageLiteral(resourceName: "callkit-icon"))
        let sut = PlaceholderInfoView.placeholderLoading(frame: frame, subtitle: "Caricamento", header: header)
        sut.backgroundColor = .red

        let host = makeHost(addingView: sut)

        verifySnapshot(host)
    }

    func testPlaceholderViewShouldShowEmptyDataSetPlaceholder() {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 700)
        let header = LoaderView(image: #imageLiteral(resourceName: "callkit-icon"))
        let sut = PlaceholderInfoView.placeholderEmptyDataset(frame: frame, title: "Title", subtitle: "Subtitle", header: header)
        sut.backgroundColor = .red

        let host = makeHost(addingView: sut)

        verifySnapshot(host)
    }

    // MARK: Helpers

    private func makeHost(addingView view: UIView) -> UIViewController {
        let host = UIViewController()
        host.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        return host
    }
}
