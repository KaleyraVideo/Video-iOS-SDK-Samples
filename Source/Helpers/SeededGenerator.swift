// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import GameKit

struct SeededGenerator : RandomNumberGenerator {

    mutating func next() -> UInt64 {
        let next1 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        let next2 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        return next1 ^ (next2 << 32)
    }

    init(seed: UInt64) {
        self.gkrandom = GKMersenneTwisterRandomSource(seed: seed)
    }

    private let gkrandom: GKRandom
}
