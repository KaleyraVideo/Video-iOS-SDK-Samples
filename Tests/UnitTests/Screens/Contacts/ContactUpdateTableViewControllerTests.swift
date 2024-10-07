// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class ContactUpdateTableViewControllerTests: UnitTestCase, CompletionSpyFactory {

    private var contact: Contact!
    private var store: AddressBook!
    private var sut: ContactProfileViewController!

    override func setUp() {
        super.setUp()

        contact = .init(alias: .alice)
        contact.firstName = "Alice"
        contact.lastName = "Appleseed"
        contact.imageURL = URL(string: .foobar)
        store = .init(repository: UserRepositoryDummy())
        sut = .init(contact: contact, book: store)
    }

    override func tearDown() {
        sut = nil
        contact = nil
        store = nil

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.ContactUpdate.title))
    }

    func testTableViewStyle() {
        assertThat(sut.tableView.style, equalTo(.insetGrouped))
    }

    func testDataSourceForTableViewSectionsAndCells() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.numberOfSections, equalTo(3))
        assertThat(sut.tableView.numberOfRows(inSection: 0), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 1), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 2), equalTo(1))
    }

    func testSetupForFirstNameTextFieldAccessoryView() throws {
        sut.loadViewIfNeeded()

        let cell = sut.cellForRowAt(.init(row: 0, section: 0))
        assertThat(cell?.text, presentAnd(equalTo(contact.firstName)))
    }

    func testSetupLastNameTextField() {
        sut.loadViewIfNeeded()

        let cell = sut.cellForRowAt(.init(row: 0, section: 1))
        assertThat(cell?.text, presentAnd(equalTo(contact.lastName)))
    }

    func testSetupAvatarTextField() {
        sut.loadViewIfNeeded()

        let cell = sut.cellForRowAt(.init(row: 0, section: 2))
        assertThat(cell?.text, presentAnd(equalTo(contact.imageURL?.absoluteString)))
    }

    func testWhenSaveButtonIsTouchedShouldInvokeOnDismissCallback() throws {
        let callback = CompletionSpy<Contact>()
        sut.onDismiss = callback.callAsFunction

        sut.loadViewIfNeeded()
        sut.simulateFirstnameUpdated("FirstName")
        sut.simulateLastnameUpdated("LastName")
        sut.footer?.button?.sendActions(for: .touchUpInside)

        assertThat(callback.invocations, hasCount(1))
        let contact = callback.invocations[0]
        assertThat(contact.firstName, equalTo("FirstName"))
        assertThat(contact.lastName, equalTo("LastName"))
    }

    func testWhenSaveButtonIsTouchedShouldUpdateContactInContactsStore() throws {
        sut.loadViewIfNeeded()

        sut.simulateFirstnameUpdated("John")
        sut.simulateLastnameUpdated("Doe")
        sut.footer?.button?.sendActions(for: .touchUpInside)

        assertThat(store.contacts, hasCount(1))
        assertThat(store.contacts[0].alias, equalTo(.alice))
        assertThat(store.contacts[0].firstName, equalTo("John"))
        assertThat(store.contacts[0].lastName, equalTo("Doe"))
    }
}

private extension ContactProfileViewController {

    var footer: ButtonTableFooter? {
        tableView.tableFooterView as? ButtonTableFooter
    }

    func cellForRowAt(_ indexPath: IndexPath) -> TextFieldTableViewCell? {
        tableView(tableView, cellForRowAt: indexPath) as? TextFieldTableViewCell
    }

    func simulateFirstnameUpdated(_ text: String) {
        let cell = cellForRowAt(.init(row: 0, section: 0))
        cell?.simulateTextChanged(text)
    }

    func simulateLastnameUpdated(_ text: String) {
        let cell = cellForRowAt(.init(row: 0, section: 1))
        cell?.simulateTextChanged(text)
    }
}

private extension ButtonTableFooter {

    var button: UIButton? {
        firstDescendant()
    }
}

private extension UITextField {

    func simulateTextEditingEnded(_ text: String) {
        self.text = text
        self.delegate?.textFieldDidEndEditing?(self)
    }
}
