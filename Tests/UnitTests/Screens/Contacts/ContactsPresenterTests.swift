// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class ContactsPresenterTests: UnitTestCase {

    private var output: ContactsPresenterOutputSpy!
    private var sut: ContactsPresenter!

    override func setUp() {
        super.setUp()

        output = .init()
        sut = .init(output: output)
    }

    override func tearDown() {
        sut = nil
        output = nil

        super.tearDown()
    }

    func testCorrectCallOfDisplayMethodForPresenter() {
        sut.didStartLoading()

        assertThat(output.displayInvocations, equalTo([.loading]))
    }

    func testReceivedDataWhenFinishLoadingUsers() {
        let contacts = Contact.makeRandomContacts(aliases: [.alice, .bob])
        sut.didFinishLoading(contacts: contacts)

        assertThat(output.displayInvocations, equalTo([.loaded(contacts)]))
    }

    func testFinishLoadingUsersWithErrorTellsOutputToDisplayNotContacts() {
        sut.didFinishLoadingWithError(errorDescription: .foo)

        assertThat(output.displayInvocations, equalTo([.error(description: .foo)]))
    }

    func testReceivedDataWhenFinishLoadingUsersWithEmptyDataset() {
        sut.didFinishLoading(contacts: [])

        assertThat(output.displayInvocations, equalTo([.loaded([])]))
    }
}

class ContactsPresenterOutputSpy: ContactsPresenterOutput {

    private(set) var displayInvocations = [ContactsViewModel.State]()

    func display(_ state: ContactsViewModel.State) {
        displayInvocations.append(state)
    }
}
