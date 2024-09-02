// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

enum RegionPresenter {

    static func localizedName(_ region: Config.Region) -> String {
        switch region {
            case .europe:
                return Strings.Setup.RegionSection.europe
            case .india:
                return Strings.Setup.RegionSection.india
            case .us:
                return Strings.Setup.RegionSection.us
            case .middleEast:
                return Strings.Setup.RegionSection.middleEast
        }
    }
}
