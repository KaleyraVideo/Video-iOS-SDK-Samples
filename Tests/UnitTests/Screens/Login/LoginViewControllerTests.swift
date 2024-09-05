// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class LoginViewControllerTests: UnitTestCase, CompletionSpyFactory {

    private var sut: LoginViewController!

    override func setUp() {
        super.setUp()

        sut = .init(services: ServicesFactoryStub())
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.Login.title))
    }

    func testsViewDidLoadNotifiesReadyListener() {
        let listener = makeVoidCompletionSpy()
        sut.onReady = listener.callAsFunction

        sut.loadViewIfNeeded()

        assertThat(listener.invocations, hasCount(1))
    }

    func testsDisplayViewModelAndReloadTableView() {
        sut.loadViewIfNeeded()

        sut.display(.loaded(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))

        assertThat(sut.tableView.numberOfRows(inSection: 0), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 1), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 2), equalTo(1))
    }

    func testsColorSectionIntexTitlesTableView() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.sectionIndexColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
    }

    func testsTableViewKeyBoardDismissMode() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.keyboardDismissMode, equalTo(.onDrag))
    }

    func testsDisplayUsernameCorreclyInTableViewCellsTitle() throws {
        sut.loadViewIfNeeded()

        let users = ["Usr1", "Usr2", "Usr3"]
        sut.display(.loaded(Contact.makeRandomContacts(aliases: users)))
        sut.tableView.frame = UIScreen.main.bounds

        for index in 0 ..< users.count {
            let cell = try unwrap(sut.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? UserCell)
            assertThat(cell.contact?.alias, equalTo(users[index]))
        }
    }

    func testShowOrHideComponentsBasedOnViewModelLoadingFlag() throws {
        sut.loadViewIfNeeded()

        sut.display(.loading)
        assertThat(sut.tableView.noContentView?.subtitle, presentAnd(equalTo(Strings.Login.loadingTitle)))

        sut.display(.loaded(Contact.makeRandomContacts(aliases: [.alice, .bob])))
        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testShowPlaceHolderEmptyDatasetWhenPassNoDataToTableView() throws {
        sut.loadViewIfNeeded()
        sut.display(.loaded([]))

        assertThat(sut.tableView.noContentView?.title, presentAnd(equalTo(Strings.Login.emptyTitle)))
        assertThat(sut.tableView.noContentView?.subtitle, presentAnd(equalTo(Strings.Login.emptySubtitle)))

        sut.display(.loaded(Contact.makeRandomContacts(aliases: [.alice, .bob])))
        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testShowPlaceHolderErrorWhenReturnUnknownError() throws {
        sut.loadViewIfNeeded()

        sut.display(.error(description: .foo))
        assertThat(sut.tableView.noContentView?.title, presentAnd(equalTo(Strings.Login.ErrorAlert.title)))
        assertThat(sut.tableView.noContentView?.subtitle, presentAnd(equalTo(.foo)))
        assertThat(sut.tableView.noContentView?.actionTitle, presentAnd(equalTo(Strings.Login.ErrorAlert.retryAction)))

        sut.display(.loaded(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))
        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testCallDidSelectRowDelegateOnTapTableViewCell() {
        sut.loadViewIfNeeded()

        let selectionSpy = makeSelectionSpy()
        sut.onSelection = selectionSpy.callAsFunction

        sut.display(.loaded(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))
        assertThat(sut.tableView.backgroundView, nilValue())

        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        assertThat(selectionSpy.invocations.map(\.alias), equalTo([.alice]))
    }

    // MARK: - Helpers

    private func makeSelectionSpy() -> CompletionSpy<Contact> {
        makeCompletionSpy()
    }
}

private extension UITableView {

    var noContentView: NoContentView? {
        backgroundView as? NoContentView
    }
}
