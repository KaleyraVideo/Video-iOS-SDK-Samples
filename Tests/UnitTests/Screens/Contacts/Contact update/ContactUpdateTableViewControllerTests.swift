// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ContactUpdateTableViewControllerTests: UnitTestCase {

    private var contact: Contact!
    private var services: ServicesFactoryStub!
    private var sut: ContactUpdateTableViewController!

    override func setUp() {
        super.setUp()

        contact = .init(.alice)
        services = .init()
        sut = .init(contact: contact, services: services)
    }

    override func tearDown() {
        sut = nil
        contact = nil
        services = nil

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.ContactUpdate.title))
    }

    func testDataSourceForTableViewSectionsAndCells() {
        let _ = sut.view

        assertThat(sut.tableView.numberOfSections, equalTo(3))
        assertThat(sut.tableView.numberOfRows(inSection: 0), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 1), equalTo(1))
        assertThat(sut.tableView.numberOfRows(inSection: 2), equalTo(1))
    }

    func testSetupForFirstNameTextFieldAccessoryView() throws {
        let _ = sut.view

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        assertThat(cell, present())
        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let firstNameTextField = try XCTUnwrap(cell.contentView.firstDescendant() as? UITextField)

        try assertTextFieldPropertyValues(textField: firstNameTextField)
    }

    func testSetupForLastNameTextFieldAccessoryView() throws {
        let _ = sut.view

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 1))

        assertThat(cell, present())
        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let lastNameTextField = try XCTUnwrap(cell.contentView.firstDescendant() as? UITextField)

        try assertTextFieldPropertyValues(textField: lastNameTextField)
    }

    func testSetupForProfileUrlTextFieldAccessoryView() throws {
        let _ = sut.view

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 2))

        assertThat(cell, present())
        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let lastNameTextField = try XCTUnwrap(cell.contentView.firstDescendant() as? UITextField)

        try assertTextFieldPropertyValues(textField: lastNameTextField)
    }

    func testOnDismissFunctionReturnUpdatedContact() throws {
        let _ = sut.view

        var contact = Contact("testAlias")
        let onDismiss: (Contact) -> Void = { updatedContact in
            contact = updatedContact
        }

        sut.onDismiss = onDismiss

        let cellFirstName = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        let firstNameTextField = try XCTUnwrap(cellFirstName.contentView.firstDescendant() as? UITextField)

        firstNameTextField.text = "FirstName"
        firstNameTextField.delegate?.textFieldDidEndEditing?(firstNameTextField)

        let cellLastName = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 1))

        let lastNameTextField = try XCTUnwrap(cellLastName.contentView.firstDescendant() as? UITextField)

        lastNameTextField.text = "LastName"
        lastNameTextField.delegate?.textFieldDidEndEditing?(lastNameTextField)

        sut.viewWillDisappear(false)

        let button = try XCTUnwrap(sut.tableView.tableFooterView?.firstDescendant() as? RoundedButton)
        button.sendActions(for: .touchUpInside)

        assertThat(contact.firstName, equalTo("FirstName"))
        assertThat(contact.lastName, equalTo("LastName"))
    }

    func testTableViewStyle() {
        assertThat(sut.tableView.style, equalTo(.insetGrouped))
    }

    // MARK: Helpers

    func assertTextFieldPropertyValues(textField: UITextField, file: StaticString = #filePath, line: UInt = #line ) throws {

        assertThat(textField.delegate, present())
        assertThat(textField.inputAccessoryView, present())

        let toolBar: UIToolbar = try XCTUnwrap(textField.inputAccessoryView as? UIToolbar)

        assertThat(toolBar.frame, equalTo(.init(x: 0, y: 0, width: 100, height: 44)))
        assertThat(toolBar.barStyle, equalTo(.default))
        assertThat(toolBar.items?.count, equalTo(2))

        let doneButtonItem = try XCTUnwrap(toolBar.items?.last)

        assertThat(doneButtonItem.style, equalTo(.plain))
        assertThat(doneButtonItem.title, equalTo(Strings.Generic.confirm))
    }
}
