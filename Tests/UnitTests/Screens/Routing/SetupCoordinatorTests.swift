// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class SetupCoordinatorTests: UnitTestCase {

    private var navigator: TestableNavigationController!

    override func setUp() {
        super.setUp()

        navigator = .init()
    }

    override func tearDown() {
        navigator = nil

        super.tearDown()
    }

    // MARK: - Tests

    func testStartShouldPresentSetupSelectionScreen() {
        let controller = UIViewController()
        let factory = SetupUIFactorySpy()
        factory.onMakeSetupSelection = {
            controller
        }
        let sut = makeSUT(factory: factory)

        sut.start()

        assertThat(navigator.viewControllers.first, presentAnd(instanceOfAnd(equalTo(controller))))
    }

    func testWhenQRCodeOptionIsSelectedShouldNavigateToQRScreen() {
        let factory = makeFactory()
        let qrController = makeViewController()
        factory.onMakeQR = { qrController }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.QR)

        assertThat(navigator.viewControllers, hasCount(2))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(qrController)))
    }

    func testWhenQRCodeIsDismissedShouldGoBackToSetupSelectionScreen() {
        let factory = makeFactory()
        let setupController = makeViewController()
        factory.onMakeSetupSelection = { setupController }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.QR)
        factory.makeQRSelectionInvocation.first?(nil)

        assertThat(navigator.viewControllers, hasCount(1))
        assertThat(navigator.viewControllers.first, presentAnd(sameInstance(setupController)))
    }

    // MARK: - Wizard

    func testWhenWizardOptionIsSelectedShouldNavigateToWizardFirstStepScreen() {
        let factory = makeFactory()
        let controller = makeViewController()
        factory.onMakeRegionSelection = { controller }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.wizard)

        assertThat(navigator.viewControllers, hasCount(2))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(controller)))
    }

    func testWhenUserSelectsRegionShouldNavigateToEnvironmentSelectionWhenRegionHasMoreThanOneEnvironment() {
        let factory = makeFactory()
        let controller = makeViewController()
        factory.onMakeEnvironmentSelection = { controller }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.wizard)
        factory.makeRegionSelectionViewControllerInvocation.first?(.europe)

        assertThat(navigator.viewControllers, hasCount(3))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(controller)))
    }

    func testWhenUserSelectsRegionShouldNavigateToCompanySelectionWhenRegionHasOnlyOneEnvironment() {
        let factory = makeFactory()
        let controller = makeViewController()
        factory.onMakeCompanySelection = { controller }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.wizard)
        factory.makeRegionSelectionViewControllerInvocation.first?(.india)

        assertThat(navigator.viewControllers, hasCount(3))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(controller)))
    }

    func testWhenUserSelectsEnvironmentShouldNavigateToCompanySelection() {
        let factory = makeFactory()
        let controller = makeViewController()
        factory.onMakeCompanySelection = { controller }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.wizard)
        factory.makeRegionSelectionViewControllerInvocation.first?(.europe)
        factory.makeEnvironmentSelectionViewControllerInvocation.first?(.sandbox)

        assertThat(navigator.viewControllers, hasCount(4))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(controller)))
    }

    func testWhenUserSelectsCompanyShouldNavigateToAdvancedSettingsScreen() {
        let factory = makeFactory()
        let controller = makeViewController()
        factory.onMakeAdvancedSettings = { controller }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.wizard)
        factory.makeRegionSelectionViewControllerInvocation.first?(.india)
        factory.makeCompanySelectionViewControllerInvocation.first?(.video)

        assertThat(navigator.viewControllers, hasCount(4))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(controller)))
    }

    // MARK: - Advanced setup

    func testUserSelectsAdvancedSetupShouldNavigateToAdvancedSetupScreen() {
        let factory = makeFactory()
        let controller = makeViewController()
        factory.onMakeAdvancedSetup = { controller }
        let sut = makeSUT(factory: factory)

        sut.start()
        factory.makeSetupSelectionInvocation.first?(.advanced)

        assertThat(navigator.viewControllers, hasCount(2))
        assertThat(navigator.viewControllers.last, presentAnd(sameInstance(controller)))
    }

    // MARK: - Helpers

    private func makeSUT(factory: SetupUIFactory & SetupWizardUIFactory & ServicesFactory) -> SetupCoordinator {
        .init(navigator: navigator, factory: factory)
    }

    private func makeFactory() -> SetupUIFactorySpy {
        .init()
    }

    private func makeViewController() -> UIViewController {
        .init()
    }

}

private class SetupUIFactorySpy: ServicesFactoryStub, SetupUIFactory, SetupWizardUIFactory {

    private(set) lazy var makeSetupSelectionInvocation = [(AppSetupType) -> Void]()
    private(set) lazy var makeQRSelectionInvocation = [(QRCode?) -> Void]()
    private(set) lazy var makeRegionSelectionViewControllerInvocation = [(Config.Region) -> Void]()
    private(set) lazy var makeEnvironmentSelectionViewControllerInvocation = [(Config.Environment) -> Void]()
    private(set) lazy var makeCompanySelectionViewControllerInvocation = [(Company) -> Void]()

    var onMakeSetupSelection: (() -> UIViewController)?
    var onMakeQR: (() -> UIViewController)?
    var onMakeRegionSelection: (() -> UIViewController)?
    var onMakeEnvironmentSelection: (() -> UIViewController)?
    var onMakeCompanySelection: (() -> UIViewController)?
    var onMakeAdvancedSettings: (() -> UIViewController)?
    var onMakeAdvancedSetup: (() -> UIViewController)?

    func makeSetupSelectionViewController(onSelection: @escaping (AppSetupType) -> Void) -> UIViewController {
        makeSetupSelectionInvocation.append(onSelection)

        guard let stub = onMakeSetupSelection else { return .init() }

        return stub()
    }

    func makeQRViewController(onDismiss: @escaping (QRCode?) -> Void) -> UIViewController {
        makeQRSelectionInvocation.append(onDismiss)

        guard let stub = onMakeQR else { return .init() }

        return stub()
    }

    func makeAdvancedSetupViewController(model: AppSetupViewModel, services: ServicesFactory) -> UIViewController {
        guard let stub = onMakeAdvancedSetup else { return .init() }
        return stub()
    }

    func makeRegionSelectionViewController(onSelection: @escaping (Config.Region) -> Void) -> UIViewController {
        makeRegionSelectionViewControllerInvocation.append(onSelection)

        guard let stub = onMakeRegionSelection else { return .init() }

        return stub()
    }

    func makeEnvironmentSelectionViewController(onSelection: @escaping (Config.Environment) -> Void) -> UIViewController {
        makeEnvironmentSelectionViewControllerInvocation.append(onSelection)

        guard let stub = onMakeEnvironmentSelection else { return .init() }

        return stub()
    }

    func makeCompanySelectionViewController(onSelection: @escaping (Company) -> Void) -> UIViewController {
        makeCompanySelectionViewControllerInvocation.append(onSelection)

        guard let stub = onMakeCompanySelection else { return .init() }

        return stub()
    }

    func makeAdvancedSettingsViewController(model: AdvancedSettingsViewModel) -> UIViewController {
        guard let stub = onMakeAdvancedSettings else { return .init() }

        return stub()
    }
}

private class TestableNavigationController: UINavigationController {

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: false)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: false)
    }

    override func show(_ vc: UIViewController, sender: Any?) {
        super.pushViewController(vc, animated: false)
    }
}
