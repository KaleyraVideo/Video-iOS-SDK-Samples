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
    private var store: ContactsStore!
    private var sut: ContactUpdateTableViewController!

    override func setUp() {
        super.setUp()

        contact = .init(.alice)
        store = .init(repository: UserRepositoryDummy())
        sut = .init(contact: contact, store: store)
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
        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let firstNameTextField = try unwrap(cell.textField)
        assertTextFieldPropertyValues(textField: firstNameTextField)
    }

    func testSetupForLastNameTextFieldAccessoryView() throws {
        sut.loadViewIfNeeded()

        let cell = sut.cellForRowAt(.init(row: 0, section: 1))
        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let lastNameTextField = try unwrap(cell.textField)
        assertTextFieldPropertyValues(textField: lastNameTextField)
    }

    func testSetupForProfileUrlTextFieldAccessoryView() throws {
        sut.loadViewIfNeeded()

        let cell = sut.cellForRowAt(.init(row: 0, section: 2))
        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let lastNameTextField = try unwrap(cell.textField)
        assertTextFieldPropertyValues(textField: lastNameTextField)
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
        sut.simulateLastnameUpdated("Appleseed")
        sut.footer?.button?.sendActions(for: .touchUpInside)

        assertThat(store.contacts, hasCount(1))
        assertThat(store.contacts[0].alias, equalTo(.alice))
        assertThat(store.contacts[0].firstName, equalTo("John"))
        assertThat(store.contacts[0].lastName, equalTo("Appleseed"))
    }

    // MARK: - Helpers

    func assertTextFieldPropertyValues(textField: UITextField, file: StaticString = #filePath, line: UInt = #line ) {
        assertThat(textField.delegate, present(), file: file, line: line)
        assertThat(textField.inputAccessoryView, present(), file: file, line: line)
        assertThat(textField.inputAccessoryView, presentAnd(instanceOf(UIToolbar.self)), file: file, line: line)
        let toolBar = textField.inputAccessoryView as! UIToolbar
        assertThat(toolBar.frame, equalTo(.init(x: 0, y: 0, width: 100, height: 44)), file: file, line: line)
        assertThat(toolBar.barStyle, equalTo(.default), file: file, line: line)
        assertThat(toolBar.items, presentAnd(hasCount(2)), file: file, line: line)
        let doneButtonItem = toolBar.items![1]
        assertThat(doneButtonItem.style, equalTo(.plain), file: file, line: line)
        assertThat(doneButtonItem.title, equalTo(Strings.Generic.confirm), file: file, line: line)
    }
}

private extension ContactUpdateTableViewController {

    var footer: ButtonTableFooter? {
        tableView.tableFooterView as? ButtonTableFooter
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        tableView(tableView, cellForRowAt: indexPath)
    }

    func simulateFirstnameUpdated(_ text: String) {
        let cell = cellForRowAt(.init(row: 0, section: 0))
        cell.textField?.simulateTextEditingEnded(text)
    }

    func simulateLastnameUpdated(_ text: String) {
        let cell = cellForRowAt(.init(row: 0, section: 1))
        cell.textField?.simulateTextEditingEnded(text)
    }
}

private extension UITableViewCell {

    var textField: UITextField? {
        contentView.firstDescendant()
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
