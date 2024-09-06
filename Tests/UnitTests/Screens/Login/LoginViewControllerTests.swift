// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class LoginViewControllerTests: UnitTestCase, CompletionSpyFactory {

    private var viewModel: ContactsViewModel!
    private var repository: UserRepositoryMock!
    private var sut: LoginViewController!

    override func setUp() {
        super.setUp()

        repository = .init()
        viewModel = .init(store: .init(repository: repository))
        sut = .init(viewModel: viewModel, services: ServicesFactoryStub())
    }

    override func tearDown() {
        sut = nil
        viewModel = nil
        repository = nil

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.Login.title))
    }

    func testLoadViewShouldSetupTableView() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.keyboardDismissMode, equalTo(.onDrag))
        assertThat(sut.tableView.sectionIndexColor?.resolvedDark, equalTo(Theme.Color.secondary.resolvedDark))
    }

    func testLoadViewSetupNavigationItem() {
        sut.loadViewIfNeeded()

        assertThat(sut.navigationItem.hidesSearchBarWhenScrolling, isFalse())
        assertThat(sut.navigationItem.searchController, present())
        assertThat(sut.navigationItem.searchController?.obscuresBackgroundDuringPresentation, presentAnd(isFalse()))
        assertThat(sut.navigationItem.searchController?.searchBar.placeholder, presentAnd(equalTo(Strings.Login.searchPlaceholder)))
    }

    func testWhenViewModelIsLoadingShouldShowNoContentViewWithLoadingMessage() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.noContentView?.subtitle, presentAnd(equalTo(Strings.Login.loadingTitle)))
    }

    func testWhenViewModelIsLoadedShouldReloadData() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])

        assertThat(sut.tableView.numberOfRows(inSection: 0), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 1), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 2), equalTo(1))
    }

    func testWhenViewModelIsLoadedShouldDisplayUserCells() throws {
        sut.loadViewIfNeeded()
        sut.tableView.frame = UIScreen.main.bounds

        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        let firstCell = sut.cellForRow(at: .init(row: 0, section: 0))
        assertThat(firstCell?.contact?.alias, equalTo(.alice))
        let secondCell = sut.cellForRow(at: .init(row: 0, section: 1))
        assertThat(secondCell?.contact?.alias, equalTo(.bob))
    }

    func testWhenViewModelIsLoadedShouldRemovePlaceholderBackgroundView() throws {
        sut.loadViewIfNeeded()
        assertThat(sut.noContentView?.subtitle, equalTo(Strings.Contacts.loadingTitle))

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])

        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testWhenViewModelIsLoadedWithAnEmptyDataSetShouldShowNoContent() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [])

        assertThat(sut.noContentView?.title, equalTo(Strings.Login.emptyTitle))
        assertThat(sut.noContentView?.subtitle, equalTo(Strings.Login.emptySubtitle))
    }

    func testWhenViewModelLoadingFailsShouldShowErrorView() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersFailure(error: anyNSError())

        assertThat(sut.noContentView?.title, equalTo(Strings.Login.ErrorAlert.title))
        assertThat(sut.noContentView?.subtitle, equalTo(String(describing: anyNSError())))
        assertThat(sut.noContentView?.actionTitle, equalTo(Strings.Login.ErrorAlert.retryAction))
    }

    func testOnRowSelectedShouldNotifyListener() throws {
        let selectionSpy = makeSelectionSpy()
        sut.onSelection = selectionSpy.callAsFunction
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])
        sut.simulateRowSelected(at: .init(row: 0, section: 1))

        assertThat(selectionSpy.invocations.map(\.alias), equalTo([.bob]))
    }

    // MARK: - Search

    func testWhenSearchFieldIsUpdatedShouldFilterContactsList() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])
        sut.navigationItem.searchController?.searchBar.simulateSearchTextChanged("bo")

        assertThat(sut.tableView.numberOfSections, equalTo(1))
    }

    func testWhenSearchIsCancelledShouldUpdateContactList() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])
        sut.navigationItem.searchController?.searchBar.simulateSearchTextChanged("bo")
        sut.navigationItem.searchController?.searchBar.simulateCancel()

        assertThat(sut.tableView.numberOfSections, equalTo(3))
    }

    // MARK: - Helpers

    private func makeSelectionSpy() -> CompletionSpy<Contact> {
        makeCompletionSpy()
    }
}

private extension LoginViewController {

    var noContentView: NoContentView? {
        tableView.noContentView
    }

    func cellForRow(at indexPath: IndexPath) -> UserCell? {
        tableView.cellForRow(at: indexPath) as? UserCell
    }

    func simulateRowSelected(at indexPath: IndexPath) {
        tableView(tableView, didSelectRowAt: indexPath)
    }
}

private extension UITableView {

    var noContentView: NoContentView? {
        backgroundView as? NoContentView
    }
}
