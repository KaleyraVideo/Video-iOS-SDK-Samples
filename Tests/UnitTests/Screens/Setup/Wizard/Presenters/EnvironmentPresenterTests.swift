// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import UIKit
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class EnvironmentPresenterTests: UnitTestCase {

    func testLocalizedName() {
        Config.Environment.allCases.forEach { env in
            assertThat(EnvironmentPresenter.localizedName(env),
                       equalTo(expectedValue(env)))
        }
    }

    private func expectedValue(_ env: Config.Environment) -> String {
        switch env {
            case .production:
                return NSLocalizedString("setup.environment_production", comment: "")
            case .sandbox:
                return NSLocalizedString("setup.environment_sandbox", comment: "")
            case .development:
                return NSLocalizedString("setup.environment_develop", comment: "")
        }
    }
}
