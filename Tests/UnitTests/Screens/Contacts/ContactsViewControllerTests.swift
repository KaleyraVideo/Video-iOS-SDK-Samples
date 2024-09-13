// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class ContactsViewControllerTests: UnitTestCase, CompletionSpyFactory {

    private var appSettings: AppSettings!
    private var viewModel: ContactsViewModel!
    private var repository: UserRepositoryMock!
    private var sut: ContactsViewController!

    override func setUp() {
        super.setUp()

        appSettings = .init()
        repository = .init()
        viewModel = .init(store: .init(repository: repository), loggedUser: Contact(alias: .alice))
        sut = .init(appSettings: appSettings, viewModel: viewModel, services: ServicesFactoryStub())
    }

    override func tearDown() {
        weak var weakSut = sut
        appSettings = nil
        viewModel = nil
        repository = nil
        sut = nil
        assertThat(weakSut, nilValue())

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.Contacts.title))
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
        assertThat(sut.navigationItem.searchController?.searchBar.placeholder, presentAnd(equalTo(Strings.Contacts.searchPlaceholder)))
    }

    func testLoadViewWhenMultipleSelectionIsDisabledShouldAddCallOptionsButtonAsRightBarButtonItem() {
        sut.loadViewIfNeeded()

        assertThat(sut.navigationItem.rightBarButtonItem, present())
        assertThat(sut.navigationItem.rightBarButtonItem?.image, presentAnd(equalTo(Icons.callSettings)))
    }

    func testLoadViewWhenMultipleSelectionIsEnabledShouldAddGroupCallBarButtonItem() {
        appSettings.callSettings.isGroup = true

        sut.loadViewIfNeeded()

        assertThat(sut.navigationItem.rightBarButtonItems, presentAnd(hasCount(2)))
        assertThat(sut.navigationItem.rightBarButtonItems![0].image, presentAnd(equalTo(Icons.callSettings)))
        assertThat(sut.navigationItem.rightBarButtonItems![1].image, presentAnd(equalTo(Icons.phone)))
        assertThat(sut.navigationItem.rightBarButtonItems![1].isEnabled, presentAnd(isFalse()))
    }

    func testLoadViewShouldStartLoading() {
        sut.loadViewIfNeeded()

        assertThat(repository.loadInvocations, hasCount(1))
    }

    func testWhenViewModelIsLoadedShouldReloadData() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])

        assertThat(sut.tableView.numberOfRows(inSection: 0), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 1), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 2), equalTo(1))
    }

    func testWhenViewModelIsLoadedShouldRemovePlaceholderBackgroundView() throws {
        sut.loadViewIfNeeded()
        assertThat(sut.noContentView?.subtitle, equalTo(Strings.Contacts.Loading.title))

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])

        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testWhenViewModelIsLoadedWithAnEmptyDataSetShouldShowNoContent() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersSuccess(users: [])

        assertThat(sut.noContentView?.title, equalTo(Strings.Contacts.NoContent.title))
        assertThat(sut.noContentView?.subtitle, equalTo(Strings.Contacts.NoContent.subtitle))
    }

    func testWhenViewModelLoadingFailsShouldShowErrorView() throws {
        sut.loadViewIfNeeded()

        try repository.simulateLoadUsersFailure(error: anyNSError())

        assertThat(sut.noContentView?.title, equalTo(Strings.Contacts.Alert.title))
        assertThat(sut.noContentView?.subtitle, equalTo(String(describing: anyNSError())))
    }

    // MARK: - Multiple selection

    func testEnableMultipleSelection() {
        sut.loadViewIfNeeded()

        appSettings.callSettings.isGroup = true

        assertThat(sut.tableView.allowsMultipleSelection, isTrue())
        assertThat(sut.tableView.allowsMultipleSelectionDuringEditing, isTrue())
        assertThat(sut.navigationItem.rightBarButtonItems, presentAnd(hasCount(2)))

        assertThat(sut.navigationItem.rightBarButtonItems![0].image, presentAnd(equalTo(Icons.callSettings)))
        assertThat(sut.navigationItem.rightBarButtonItems![1].image, presentAnd(equalTo(Icons.phone)))
        assertThat(sut.navigationItem.rightBarButtonItems![1].isEnabled, presentAnd(isFalse()))
    }

    func testDisableMultipleSelection() {
        sut.loadViewIfNeeded()

        appSettings.callSettings.isGroup = true
        appSettings.callSettings.isGroup = false

        assertThat(sut.tableView.allowsMultipleSelection, isFalse())
        assertThat(sut.tableView.allowsMultipleSelectionDuringEditing, isFalse())
        assertThat(sut.navigationItem.rightBarButtonItems, presentAnd(hasCount(1)))
        assertThat(sut.navigationItem.rightBarButtonItems![0].image, presentAnd(equalTo(Icons.callSettings)))
    }

    func testWhenMoreThanOneUserIsSelectedShouldEnableGroupCallButton() throws {
        sut.loadViewIfNeeded()
        appSettings.callSettings.isGroup = true

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])

        sut.selectRow(at: .init(row: 0, section: 0))
        sut.selectRow(at: .init(row: 0, section: 1))
        assertThat(sut.navigationItem.rightBarButtonItems?.first?.isEnabled, presentAnd(isTrue()))
    }

#if SAMPLE_CUSTOMIZABLE_THEME
    func testThemableBehavior() {
        let theme = AppTheme.defaultDarkTheme()

        sut.themeChanged(theme: theme)

        assertThat(sut.view.backgroundColor, equalTo(theme.primaryBackgroundColor.toUIColor()))
        assertThat(sut.tableView.backgroundColor, equalTo(theme.secondaryBackgroundColor.toUIColor()))
        assertThat(sut.tableView.sectionIndexColor, equalTo(theme.accentColor.toUIColor()))
        assertThat(sut.tableView.tintColor, equalTo(theme.accentColor.toUIColor()))
    }
#endif

    // MARK: - Cell actions

    func testSwipeActionConfigurationsForCellOnSwipe() throws {
        sut.loadViewIfNeeded()
        try repository.simulateLoadUsersSuccess(users: [.alice, .bob, .charlie])

        let configuration = try unwrap(sut.trailingSwipeActions(at: .init(row: 0, section: 0)))
        assertThat(configuration.actions, presentAnd(hasCount(3)))

        let callAction = configuration.actions[0]
        assertThat(callAction.backgroundColor, equalTo(Theme.Color.primary))
        assertThat(callAction.title, equalTo(Strings.Contacts.Actions.call))
        assertThat(callAction.style, equalTo(.normal))
        assertThat(callAction.image, equalTo(Icons.phone))

        let videoAction = configuration.actions[1]
        assertThat(videoAction.backgroundColor, equalTo(Theme.Color.primary))
        assertThat(videoAction.title, equalTo(Strings.Contacts.Actions.video))
        assertThat(videoAction.style, equalTo(.normal))
        assertThat(videoAction.image, equalTo(Icons.videoCallAction))

        let chatAction = configuration.actions[2]
        assertThat(chatAction.backgroundColor, equalTo(Theme.Color.primary))
        assertThat(chatAction.title, equalTo(Strings.Contacts.Actions.chat))
        assertThat(chatAction.style, equalTo(.normal))
        assertThat(chatAction.image, equalTo(Icons.chatAction))
    }

    // MARK: - Bar button actions

    func testWhenCallSettingsButtonIsTouchedShouldNotifyListener() {
        let listener = makeVoidCompletionSpy()
        sut.onCallSettingsSelected = listener.callAsFunction
        sut.loadViewIfNeeded()

        sut.navigationItem.rightBarButtonItems?.first?.simulateTapped()

        assertThat(listener.invocations, hasCount(1))
    }

    func testWhenGroupCallButtonIsTouchedShouldNotifyListener() throws {
        let listener = makeActionListener()
        sut.onActionSelected = listener.callAsFunction
        sut.loadViewIfNeeded()
        appSettings.callSettings.isGroup = true
        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie, .dave])

        sut.selectRow(at: .init(row: 0, section: 0))
        sut.selectRow(at: .init(row: 0, section: 1))
        sut.navigationItem.rightBarButtonItems?.last?.simulateTapped()

        assertThat(listener.invocations, hasCount(1))
        assertThat(listener.invocations.first, equalTo(.startCall(type: nil, callees: [.bob, .charlie])))
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

    private func makeSelectionSpy() -> CompletionSpy<[String]> {
        makeCompletionSpy()
    }

    private func makeActionListener() -> CompletionSpy<ContactsViewController.Action> {
        makeCompletionSpy()
    }
}

private extension ContactsViewController {

    var noContentView: NoContentView? {
        tableView.backgroundView as? NoContentView
    }

    func selectRow(at indexPath: IndexPath) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    func trailingSwipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        tableView.delegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
}
