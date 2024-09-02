// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class AppSetupTypePresenterTests: UnitTestCase {

    func testLocalizedName() {
        assertThat(AppSetupTypePresenter.localizedName(.QR), equalToLocalizedString("app_setup_type.qr", bundle: .main))
        assertThat(AppSetupTypePresenter.localizedName(.wizard), equalToLocalizedString("app_setup_type.wizard", bundle: .main))
        assertThat(AppSetupTypePresenter.localizedName(.advanced), equalToLocalizedString("app_setup_type.advanced", bundle: .main))
    }
}
