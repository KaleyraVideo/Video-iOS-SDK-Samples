// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class ContactsViewModelTests: UnitTestCase {

    private var sut: ContactsViewModel!
    private var presenter: ContactsPresenterSpy!
    private var repository: UserRepositoryMock!

    override func setUp() {
        super.setUp()

        presenter = .init()
        repository = .init()
        sut = .init(presenter: presenter, store: .init(repository: repository), loggedUser: .alice)
    }

    override func tearDown() {
        weak var weakSut = sut
        sut = nil
        repository = nil
        presenter = nil
        assertThat(weakSut, nilValue())

        super.tearDown()
    }

    func testLoadShouldUpdateStateToLoading() throws {
        sut.load()

        assertThat(sut.state, equalTo(.loading))
        assertThat(presenter.loadingInvocations.count, equalTo(1))
    }

    func testOnLoadSuccessShouldUpdateStateToLoaded() throws  {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: [.bob, .charlie])

        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob, .charlie]))
        assertThat(presenter.finishedInvocations, hasCount(1))
        assertThat(presenter.finishedInvocations[0].map(\.alias), equalTo([.bob, .charlie]))
    }

    func testOnLoadSuccessShouldFilterLoggedUserFromContacts() throws {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob]))
        assertThat(presenter.finishedInvocations, hasCount(1))
        assertThat(presenter.finishedInvocations[0].map(\.alias), equalTo([.bob]))
    }

    func testFilterShouldUpdateContactsFilteringByAlias() throws {
        sut.load()
        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        sut.filter(searchFilter: .alice)
        assertThat(sut.state.contacts.map(\.alias), equalTo([]))
        assertThat(presenter.finishedInvocations, hasCount(2))
        assertThat(presenter.finishedInvocations[1].map(\.alias), equalTo([]))

        sut.filter(searchFilter: "")
        assertThat(sut.state.contacts.map(\.alias), equalTo([.bob]))
        assertThat(presenter.finishedInvocations, hasCount(3))
        assertThat(presenter.finishedInvocations[2].map(\.alias), equalTo([.bob]))
    }

    func testLoadSuccessShouldUpdateStateOrderingResultsAlphabetically() throws  {
        sut.load()

        try repository.simulateLoadUsersSuccess(users: ["b", "C", "d", "A"])

        assertThat(sut.state.contacts.map(\.alias), equalTo(["A", "b", "C", "d"]))
        assertThat(presenter.loadingInvocations.count, equalTo(1))
        assertThat(presenter.finishedInvocations.first?.map(\.alias), equalTo(["A", "b", "C", "d"]))
    }

    func testoadFailureShouldUpdateStateToError() throws {
        sut.load()

        try repository.simulateLoadUsersFailure(error: anyNSError())

        assertThat(sut.state, equalTo(.error(description: String(describing: anyNSError()))))
        assertThat(presenter.errorInvocations.count, equalTo(1))
    }

    func testSimulateLoadUserAndUpdateOneUserValues() throws {
        sut.load()
        try repository.simulateLoadUsersSuccess(users: [.charlie, .bob])

        var contact = Contact(.charlie)
        contact.firstName = "Charlie"
        contact.lastName = "Appleseed"
        contact.profileImageURL = .kaleyra
        sut.update(contact: contact)

        assertThat(presenter.finishedInvocations, hasCount(2))

        let actual = presenter.finishedInvocations[1][1]
        assertThat(actual.firstName, equalTo("Charlie"))
        assertThat(actual.lastName, equalTo("Appleseed"))
        assertThat(actual.profileImageURL, equalTo(.kaleyra))
    }

    func testDoesNotCreateRetainCycleWhenInvokingLoadUsers() {
        sut.load()
    }
}

class ContactsPresenterSpy: ContactsPresenter {

    private(set) lazy var loadingInvocations: [Void] = [Void]()
    private(set) lazy var errorInvocations: [String] = [String]()
    private(set) lazy var finishedInvocations = [[Contact]]()

    init() {
        super.init(output: ContactsPresenterOutputSpy())
    }

    override func didStartLoading() {
        super.didStartLoading()
        loadingInvocations.append()
    }

    override func didFinishLoadingWithError(errorDescription error: String) {
        super.didFinishLoadingWithError(errorDescription: error)
        errorInvocations.append(error)
    }

    override func didFinishLoading(contacts: [Contact]) {
        super.didFinishLoading(contacts: contacts)
        finishedInvocations.append(contacts)
    }
}
