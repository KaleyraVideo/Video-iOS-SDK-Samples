// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class CompanyPresenterTests: UnitTestCase {

    func testLocalizableName() {
        assertThat(CompanyPresenter.localizedName(.sales), equalToLocalizedString("setup.company.sales", bundle: .main))
        assertThat(CompanyPresenter.localizedName(.video), equalToLocalizedString("setup.company.video", bundle: .main))
    }
}
