// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

enum EnvironmentPresenter {

    static func localizedName(_ env: Config.Environment) -> String {
        switch env {
            case .production:
                return Strings.Setup.EnvironmentSection.production
            case .sandbox:
                return Strings.Setup.EnvironmentSection.sandbox
            case .development:
                return Strings.Setup.EnvironmentSection.develop
        }
    }
}
