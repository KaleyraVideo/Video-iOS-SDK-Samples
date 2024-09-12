// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class SetupCoordinator: BaseCoordinator {

    private let navigator: UINavigationController
    private let factory: SetupUIFactory & SetupWizardUIFactory

    init(navigator: UINavigationController, factory: SetupUIFactory & SetupWizardUIFactory & ServicesFactory) {
        self.navigator = navigator
        self.factory = factory
        super.init(services: factory)
    }

    func start() {
        goToFirstStep()
    }

    private func goToFirstStep() {
        let controller = factory.makeSetupSelectionViewController { [weak self] selection in
            guard let self else { return }

            switch selection {
                case .QR:
                    self.goToQR()
                case .wizard:
                    self.goToWizard()
                case .advanced:
                    self.goToAdvancedSetup()
            }
        }

        setController(controller)
    }

    private func goToQR() {
        let controller = factory.makeQRViewController { [weak self] config in
            guard let self else { return }

            if let config = config {

            } else {
                self.pop()
            }
        }
        push(controller)
    }

    private func goToWizard() {
        let controller = factory.makeRegionSelectionViewController { [weak self] region in
            guard let self else { return }

            if Config.Environment.environmentsFor(region: region).count > 1 {
                self.goToEnvironmentSelection(region: region)
            } else {
                self.goToCompanySelection(region: region, environment: .production)
            }

        }
        push(controller)
    }

    private func goToAdvancedSetup() {
        let model = AppSetupViewController.ViewModel()
        let controller = factory.makeAdvancedSetupViewController(model: model, services: services)
        let buttonWrapper = BarButtonItemActionWrapper {

        }
        controller.navigationItem.rightBarButtonItem = buttonWrapper.makeBarButtonItem()
        push(controller)
    }

    private func goToEnvironmentSelection(region: Config.Region) {
        let controller = factory.makeEnvironmentSelectionViewController { [weak self] environment in
            guard let self else { return }

            self.goToCompanySelection(region: region, environment: environment)
        }
        push(controller)
    }

    private func goToCompanySelection(region: Config.Region, environment: Config.Environment) {
        let controller = factory.makeCompanySelectionViewController { [weak self] company in
            guard let self else { return }

            self.goToAdvancedSettings(region: region, environment: environment, company: company)
        }
        push(controller)
    }

    private func goToAdvancedSettings(region: Config.Region, environment: Config.Environment, company: Company) {
        let model = AdvancedSettingsViewModel()
        let controller = factory.makeAdvancedSettingsViewController(model: model)
        let buttonWrapper = BarButtonItemActionWrapper {

        }
        controller.navigationItem.rightBarButtonItem = buttonWrapper.makeBarButtonItem()
        push(controller)
    }

    // MARK: - Navigation

    private func setController(_ controller: UIViewController) {
        navigator.setViewControllers([controller], animated: true)
    }

    private func push(_ controller: UIViewController) {
        navigator.show(controller, sender: self)
    }

    private func pop() {
        navigator.popViewController(animated: true)
    }
}

private class BarButtonItemActionWrapper: NSObject {

    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc
    func buttonTouched(_ sender: UIBarButtonItem) {
        action()
    }

    func makeBarButtonItem() -> UIBarButtonItem {
        .init(title: "next", style: .plain, target: self, action: #selector(buttonTouched(_:)))
    }
}
