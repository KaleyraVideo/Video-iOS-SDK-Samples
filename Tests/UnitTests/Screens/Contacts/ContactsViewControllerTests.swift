// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class ContactsViewControllerTests: UnitTestCase, CompletionSpyFactory {

    private var sut: ContactsViewController!

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

        assertThat(sut.title, equalTo(Strings.Contacts.title))
    }

    func testContactsViewControllerOnReadyListenerStarts() throws {
        let readyListener = CompletionSpy<Void>()
        sut.onReady = readyListener.callAsFunction

        sut.loadViewIfNeeded()

        assertThat(readyListener.invocations, hasCount(1))
    }

    func testsDisplayViewModelAndReloadTableView() {
        sut.loadViewIfNeeded()

        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))

        assertThat(sut.tableView.numberOfRows(inSection: 0), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 1), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 2), equalTo(1))
    }

    func testCheckChangesUIStatesWhileLoadingUsers() {
        sut.loadViewIfNeeded()

        sut.display(.loading)
        assertThat(sut.noContentView?.subtitle, equalTo(Strings.Contacts.loadingTitle))

        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob])))
        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testShowPlaceHolderEmptyDatasetWhenPassNoDataToTableView() {
        sut.loadViewIfNeeded()
        sut.display(.finished([]))

        assertThat(sut.noContentView?.title, equalTo(Strings.Contacts.emptyTitle))
        assertThat(sut.noContentView?.subtitle, equalTo(Strings.Contacts.emptySubtitle))

        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob])))
        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testShowPlaceHolderErrorWhenReturnUnknownError() {
        sut.loadViewIfNeeded()
        sut.display(.error(message: .foo))

        assertThat(sut.noContentView?.title, equalTo(Strings.Contacts.Alert.title))
        assertThat(sut.noContentView?.subtitle, equalTo(.foo))

        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob])))
        assertThat(sut.tableView.backgroundView, nilValue())
    }

    func testEnableMultipleSelectionSettings() {
        sut.loadViewIfNeeded()

        sut.enableMultipleSelection(false)

        assertThat(sut.tableView.allowsMultipleSelection, isTrue())
        assertThat(sut.tableView.allowsMultipleSelectionDuringEditing, isTrue())
    }

    func testDisableMultipleSelectionSettings() {
        sut.loadViewIfNeeded()

        sut.disableMultipleSelection(false)

        assertThat(sut.tableView.allowsMultipleSelection, isFalse())
        assertThat(sut.tableView.allowsMultipleSelectionDuringEditing, isFalse())
    }

    func testDismissKeyBoardMode() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.keyboardDismissMode, equalTo(.onDrag))
    }

    func testSelectionOfUserWhenEnabled() {
        sut.loadViewIfNeeded()
        sut.enableMultipleSelection(false)

        let selectionHandler = makeSelectionSpy()
        sut.onUpdateSelectedContacts = selectionHandler.callAsFunction
        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))

        sut.selectRow(at: .init(row: 0, section: 0))
        assertThat(selectionHandler.invocations.first, equalTo([.alice]))
    }

    func testSelectionOfUserWhenDisabled() {
        sut.loadViewIfNeeded()
        sut.disableMultipleSelection(false)

        let selectionHandler = makeSelectionSpy()
        sut.onUpdateSelectedContacts = selectionHandler.callAsFunction
        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))

        sut.selectRow(at: .init(row: 0, section: 0))
        assertThat(selectionHandler.invocations, empty())
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
#else
    func testsColorSectionIntexTitlesTableView() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.sectionIndexColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
    }
#endif

    func testSwipeActionConfigurationsForCellOnSwipe() throws {
        sut.loadViewIfNeeded()
        sut.display(.finished(Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])))

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

    // MARK: - Helpers

    private func makeSelectionSpy() -> CompletionSpy<[String]> {
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
