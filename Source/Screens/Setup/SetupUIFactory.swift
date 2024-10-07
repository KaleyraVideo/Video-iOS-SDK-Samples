// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

protocol SetupUIFactory {

    func makeSetupSelectionViewController(onSelection: @escaping (AppSetupType) -> Void) -> UIViewController
    func makeQRViewController(onDismiss: @escaping (QRCode?) -> Void) -> UIViewController
    func makeAdvancedSetupViewController(model: AppSetupViewController.ViewModel) -> UIViewController
}

protocol SetupWizardUIFactory {

    func makeRegionSelectionViewController(onSelection: @escaping (Config.Region) -> Void) -> UIViewController
    func makeEnvironmentSelectionViewController(onSelection: @escaping (Config.Environment) -> Void) -> UIViewController
    func makeCompanySelectionViewController(onSelection: @escaping (Company) -> Void) -> UIViewController
    func makeAdvancedSettingsViewController(model: AdvancedSettingsViewModel) -> UIViewController
}

struct DefaultSetupUIFactory: SetupUIFactory, SetupWizardUIFactory {

    func makeSetupSelectionViewController(onSelection: @escaping (AppSetupType) -> Void) -> UIViewController {
        makeSingleChoiceViewController(options: AppSetupType.allCases, presenter: AppSetupTypePresenter.localizedName(_:), onSelection: onSelection)
    }

    func makeQRViewController(onDismiss: @escaping (QRCode?) -> Void) -> UIViewController {
        let controller = QRReaderViewController(camera: .init())
        controller.onDismiss = onDismiss
        return controller
    }

    func makeAdvancedSetupViewController(model: AppSetupViewController.ViewModel) -> UIViewController {
        AppSetupViewController(model: model)
    }

    func makeRegionSelectionViewController(onSelection: @escaping (Config.Region) -> Void) -> UIViewController {
        makeSingleChoiceViewController(options: Config.Region.allCases, presenter: RegionPresenter.localizedName(_:), onSelection: onSelection)
    }

    func makeEnvironmentSelectionViewController(onSelection: @escaping (Config.Environment) -> Void) -> UIViewController {
        makeSingleChoiceViewController(options: Config.Environment.allCases, presenter: EnvironmentPresenter.localizedName(_:), onSelection: onSelection)
    }

    func makeCompanySelectionViewController(onSelection: @escaping (Company) -> Void) -> UIViewController {
        makeSingleChoiceViewController(options: Company.allCases, presenter: CompanyPresenter.localizedName(_:), onSelection: onSelection)
    }

    func makeAdvancedSettingsViewController(model: AdvancedSettingsViewModel) -> UIViewController {
        AdvancedSettingsSetupViewController(model: model)
    }

    private func makeSingleChoiceViewController<Option: Equatable>(options: [Option], presenter: @escaping (Option) -> String, onSelection: @escaping (Option) -> Void) -> UIViewController {
        let controller = SingleChoiceSelectionViewController(options: options, presenter: presenter)
        controller.onSelection = onSelection
        return controller
    }
}
