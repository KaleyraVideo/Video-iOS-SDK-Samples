// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class LoginLoaderPresentationAdapterTests: UnitTestCase {

    private var sut: LoginLoaderPresentationAdapter!
    private var presenter: ContactsPresenterSpy!
    private var repository: UserRepositoryMock!

    override func setUp() {
        super.setUp()

        repository = .init()
        presenter = .init()
        sut = .init(store: .init(repository: repository), presenter: presenter)
    }

    override func tearDown() {
        weak var weakSut = sut
        sut = nil
        presenter = nil
        repository = nil
        assertThat(weakSut, nilValue())

        super.tearDown()
    }

    func testFetchUsersTellsPresenterDidStartLoadingUsers() {
        sut.fetchUsers()

        assertThat(presenter.loadingInvocations, hasCount(1))
    }

    func testOnLoadUsersSuccessTellsPresenterDidFinishLoadingWithUsers() throws  {
        sut.fetchUsers()
        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        assertThat(presenter.finishedInvocations, hasCount(1))
        assertThat(presenter.finishedInvocations[0].map(\.alias), equalTo([.alice, .bob]))
    }

    func testOnLoadUsersSuccessTellsPresenterDidFinishLoadingWithUsersAndChechTheyAreAlpabeticallyOrdered() throws  {
        sut.fetchUsers()
        try repository.simulateLoadUsersSuccess(users: ["b", "C", "d", "A"])

        assertThat(presenter.finishedInvocations, hasCount(1))
        assertThat(presenter.finishedInvocations[0].map(\.alias), equalTo(["A", "b", "C", "d"]))
    }

    func testOnLoadUserSuccessTellePresenterDidFinishLoadWithUserAndTestFilteringUser() throws {
        sut.fetchUsers()
        try repository.simulateLoadUsersSuccess(users: [.alice, .bob])

        assertThat(presenter.finishedInvocations, hasCount(1))
        assertThat(presenter.finishedInvocations[0].map(\.alias), equalTo([.alice, .bob]))

        sut.filter(searchFilter: .alice)

        assertThat(presenter.finishedInvocations, hasCount(2))
        assertThat(presenter.finishedInvocations[1].map(\.alias), equalTo([.alice]))

        sut.filter(searchFilter: "")

        assertThat(presenter.finishedInvocations, hasCount(3))
        assertThat(presenter.finishedInvocations[2].map(\.alias), equalTo([.alice, .bob]))
    }

    func testOnLoadUsersFailureTellsPresenterDidFinishLoadingWithError() throws {
        sut.fetchUsers()
        try repository.simulateLoadUsersFailure(error: anyNSError())

        assertThat(presenter.errorInvocations, hasCount(1))
    }

    func testDoesNotCreateRetainCycleWhenInvokingLoadUsers() {
        sut.fetchUsers()
    }
}
