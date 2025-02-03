// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct Section<Item> {

    var items: [Item]

    var numberOfItems: Int {
        items.count
    }

    func item(at index: Int) -> Item {
        items[index]
    }
}
