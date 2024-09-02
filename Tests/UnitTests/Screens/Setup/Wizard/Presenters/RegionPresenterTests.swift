// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import UIKit
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class RegionPresenterTests: UnitTestCase {

    func testLocalizedName() {
        Config.Region.allCases.forEach { region in
            assertThat(RegionPresenter.localizedName(region),
                       equalTo(expectedValue(region)))
        }
    }

    private func expectedValue(_ region: Config.Region) -> String {
        switch region {
            case .europe:
                return NSLocalizedString("setup.region_europe", comment: "")
            case .india:
                return NSLocalizedString("setup.region_india", comment: "")
            case .us:
                return NSLocalizedString("setup.region_us", comment: "")
            case .middleEast:
                return NSLocalizedString("setup.region_middle_east", comment: "")
        }
    }
}
