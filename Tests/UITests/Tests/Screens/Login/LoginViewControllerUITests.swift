// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class LoginViewControllerUITests: SnapshotTestCase {

    let contactsGenerator = ContactsGenerator(seed: UInt64(100))

    func testEmptyDataSet() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()

        sut.display(contacts: [])

        verifySnapshot(sut)
    }

    func testDisplaysUserList() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()

        sut.display(contacts: contactsGenerator.generateContacts(from: ["usr1", "usr2", "usr3"]))

        verifySnapshot(sut)
    }

    func testLoaderAppearanceCorrectlyCenteredInScreen() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()

        sut.display(contacts: [])

        let loaderView = LoaderView(image: Icons.logo256)
        let placeholderLoading = PlaceholderInfoView.placeholderLoading(frame: sut.view.frame, subtitle: "Caricamento", header: loaderView)
        sut.view.addSubview(placeholderLoading)
        loaderView.startAnimating(with: 1)

        verifySnapshot(sut)
    }

    // MARK: - Helpers

    private func makeSUT() -> LoginViewController {
#if SAMPLE_CUSTOMIZABLE_THEME
        LoginViewController(themeStorage: DummyThemeStorage())
#else
        LoginViewController()
#endif
    }
}
