// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class ContactsViewModelTests: UnitTestCase {

    private var sut: ContactsViewModel!
    private var repository: UserRepositoryMock!

    override func setUp() {
        super.setUp()

        repository = .init()
        sut = .init(book: .init(repository: repository), loggedUser: Contact(alias: .alice))
    }

    override func tearDown() {
        weak var weakSut = sut
        sut = nil
        repository = nil
        assertThat(weakSut, nilValue())

        super.tearDown()
    }

    func testLoadShouldUpdateStateToLoading() throws {
        sut.load()

        assertThat(sut.state, equalTo(.loading))
    }

    func testOnLoadSuccessShouldUpdateStateToLoaded() throws  {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie])

        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob, .charlie]))
    }

    func testOnLoadSuccessShouldFilterLoggedUserFromContacts() throws {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob]))
    }

    func testFilterShouldUpdateContactsFilteringByAlias() throws {
        sut.load()
        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        sut.filter(searchFilter: .alice)
        assertThat(sut.state.contacts.map(\.alias), equalTo([]))

        sut.filter(searchFilter: "")
        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob]))
    }

    func testLoadSuccessShouldUpdateStateOrderingResultsAlphabetically() throws  {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: ["b", "C", "d", "A"])

        assertThat(sut.state.contacts.map(\.alias), equalTo(["A", "b", "C", "d"]))
    }

    func testLoadFailureShouldUpdateStateToError() throws {
        sut.load()

        try repository.simulateLoadUsersFailure(error: anyNSError())

        let description = String(describing: anyNSError())
        assertThat(sut.state, equalTo(.error(description: description)))
    }

    func testSimulateLoadUserAndUpdateOneUserValues() throws {
        sut.load()
        try repository.simulateLoadUsersSuccess(users: [.charlie, .bob])

        var contact = Contact(alias: .charlie)
        contact.firstName = "Charlie"
        contact.lastName = "Appleseed"
        contact.imageURL = .kaleyra
        sut.update(contact: contact)

        let actual = sut.state.contacts[1]
        assertThat(actual.firstName, equalTo("Charlie"))
        assertThat(actual.lastName, equalTo("Appleseed"))
        assertThat(actual.imageURL, equalTo(.kaleyra))
    }
}
