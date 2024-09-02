// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import CallKit
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
import KaleyraVideoSDK
@testable import SDK_Sample

final class ContactsUserDetailsProviderTests: UnitTestCase {

    func testProvideDetailsShouldReturnUserDetailsFilledWithInformationFromContact() {
        let contacts = Contact.makeRandomContacts(aliases: [.alice, .bob, .charlie])
        let sut = ContactsUserDetailsProvider(contacts: contacts)
        let completion = CompletionSpy<Result<[KaleyraVideoSDK.UserDetails], Error>>()

        sut.provideDetails([.alice], completion: completion.callAsFunction)

        assertThat(completion.invocations.first, presentAnd(isSuccess(withValue: equalTo([contacts.first(where: { $0.alias == .alice })!.userDetails]))))
    }
}
