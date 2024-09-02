// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import KaleyraTestKit
@testable import SDK_Sample

final class ColorTableViewCellUITests: SnapshotTestCase {

    func testDisplayCellWithNameAndColor() {
        let host = SingleCellTableViewController(cellProvider: { table, index in
            let cell = ColorTableViewCell()
            cell.color = .red
            cell.title = "I'm a title"
            return cell
        }, height: 50)

        verifySnapshot(host)
    }

}
