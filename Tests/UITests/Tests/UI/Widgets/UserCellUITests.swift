// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class UserCellUITests: SnapshotTestCase {

    func testAppearanceOfContactCellNormalState() {
        let sut = makeViewController(contact: makeContact(), height: 100)

        verifySnapshot(sut)
    }

    func testAppearanceOfContactCellSmallHeight() {
        let sut = makeViewController(contact: makeContact(), height: 40)

        verifySnapshot(sut)
    }

    func testAppearanceOfContactCellLargeHeight() {
        let sut = makeViewController(contact: makeContact(), height: 250)

        verifySnapshot(sut)
    }

    func testAppearanceOfContactCellWithLongName() {
        let sut = makeViewController(contact: makeContactWithLongName(), height: 100)

        verifySnapshot(sut)
    }

    //MARK: Helpers

    private func makeViewController(contact: Contact, height: CGFloat) -> UIViewController {
        return SingleCellTableViewController(cellProvider:{ (c, i) in
            c.registerReusableCell(UserCell.self)
            let cell: UserCell = c.dequeueReusableCell(for: i)
            cell.backgroundColor = UIColor.white
            cell.contact = contact
            return cell
        }, height: height)
    }

    private func makeContact() -> Contact {
        var contact = Contact("arc1")
        contact.profileImage = "man_0.jpg"
        contact.firstName = "Pippo"
        contact.lastName = "Pluto"

        return contact
    }

    private func makeContactWithLongName() -> Contact {
        var contact = Contact("arc1")
        contact.profileImage = "man_0.jpg"
        contact.firstName = "Lorem ipsum dolor sit amet, consectetur adipisci elit, sed do eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrum exercitationem ullamco laboriosam, nisi ut aliquid ex ea commodi consequatur. Duis aute irure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur"
        contact.lastName = ""

        return contact
    }
}
