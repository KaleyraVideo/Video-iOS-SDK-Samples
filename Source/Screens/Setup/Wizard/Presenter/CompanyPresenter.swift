// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct CompanyPresenter {

    static func localizedName(_ company: Company) -> String {
        switch company {
            case .video:
                return Strings.Setup.CompanySection.video
            case .sales:
                return Strings.Setup.CompanySection.sales
        }
    }
}
