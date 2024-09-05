// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class ContactsViewModelTests: UnitTestCase {

    private var sut: ContactsViewModel!
    private var observer: ContactsViewModelObserverSpy!
    private var repository: UserRepositoryMock!

    override func setUp() {
        super.setUp()

        observer = .init()
        repository = .init()
        sut = .init(store: .init(repository: repository), loggedUser: .alice)
        sut.observer = observer
    }

    override func tearDown() {
        weak var weakSut = sut
        sut = nil
        repository = nil
        observer = nil
        assertThat(weakSut, nilValue())

        super.tearDown()
    }

    func testLoadShouldUpdateStateToLoading() throws {
        sut.load()

        assertThat(sut.state, equalTo(.loading))
        assertThat(observer.displayInvocations, hasCount(1))
        assertThat(observer.displayInvocations[0], equalTo(.loading))
    }

    func testOnLoadSuccessShouldUpdateStateToLoaded() throws  {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie])

        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob, .charlie]))
        assertThat(observer.displayInvocations, hasCount(2))
        assertThat(observer.displayInvocations[1].contacts.map(\.alias), equalTo([.bob, .charlie]))
    }

    func testOnLoadSuccessShouldFilterLoggedUserFromContacts() throws {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob]))
        assertThat(observer.displayInvocations, hasCount(2))
        assertThat(observer.displayInvocations[1].contacts.map(\.alias), equalTo([.bob]))
    }

    func testFilterShouldUpdateContactsFilteringByAlias() throws {
        sut.load()
        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        sut.filter(searchFilter: .alice)
        assertThat(sut.state.contacts.map(\.alias), equalTo([]))
        assertThat(observer.displayInvocations, hasCount(3))
        assertThat(observer.displayInvocations[2].contacts.map(\.alias), equalTo([]))

        sut.filter(searchFilter: "")
        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob]))
        assertThat(observer.displayInvocations, hasCount(4))
        assertThat(observer.displayInvocations[3].contacts.map(\.alias), equalTo([.bob]))
    }

    func testLoadSuccessShouldUpdateStateOrderingResultsAlphabetically() throws  {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: ["b", "C", "d", "A"])

        assertThat(sut.state.contacts.map(\.alias), equalTo(["A", "b", "C", "d"]))
        assertThat(observer.displayInvocations, hasCount(2))
        assertThat(observer.displayInvocations[1].contacts.map(\.alias), equalTo(["A", "b", "C", "d"]))
    }

    func testLoadFailureShouldUpdateStateToError() throws {
        sut.load()

        try repository.simulateLoadUsersFailure(error: anyNSError())

        let description = String(describing: anyNSError())
        assertThat(sut.state, equalTo(.error(description: description)))
        assertThat(observer.displayInvocations, hasCount(2))
        assertThat(observer.displayInvocations[1], equalTo(.error(description: description)))
    }

    func testSimulateLoadUserAndUpdateOneUserValues() throws {
        sut.load()
        try repository.simulateLoadUsersSuccess(users: [.charlie, .bob])

        var contact = Contact(.charlie)
        contact.firstName = "Charlie"
        contact.lastName = "Appleseed"
        contact.imageURL = .kaleyra
        sut.update(contact: contact)

        assertThat(observer.displayInvocations, hasCount(3))

        let actual = observer.displayInvocations[2].contacts[1]
        assertThat(actual.firstName, equalTo("Charlie"))
        assertThat(actual.lastName, equalTo("Appleseed"))
        assertThat(actual.imageURL, equalTo(.kaleyra))
    }

    func testDoesNotCreateRetainCycleWhenInvokingLoadUsers() {
        sut.load()
    }
}
