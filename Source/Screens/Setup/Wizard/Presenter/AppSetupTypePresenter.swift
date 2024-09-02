// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

enum AppSetupTypePresenter {

    static func localizedName(_ type: AppSetupType) -> String {
        switch type {
            case .QR:
                return Strings.AppSetupType.qr
            case .wizard:
                return Strings.AppSetupType.wizard
            case .advanced:
                return Strings.AppSetupType.advanced
        }
    }
}
