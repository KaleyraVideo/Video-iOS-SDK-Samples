// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit
import MessageUI

final class RootCoordinator: BaseCoordinator {

    var controller: UIViewController { pageController }

    private lazy var pageController: UIPageViewController = .init(transitionStyle: .scroll, navigationOrientation: .horizontal)

    private let settingsRepository: SettingsRepository

    private var mainCoordinator: MainCoordinator? {
        children.compactMap({ $0 as? MainCoordinator }).first
    }

    private lazy var logService: LogServiceProtocol = services.makeLogService()

    private enum State {
        case startup(config: Config? = nil)
        case userChange(config: Config)
        case configured(config: Config, userId: String)

        mutating func loadFromDefaults(_ repository: SettingsRepository) {
            let config = try? repository.loadConfig()
            let user = repository.loadLoggedUser()

            switch (config, user) {
                case (.none, .none):
                    self = .startup(config: nil)
                case (.some(let config), .none):
                    self = .startup(config: config)
                case (.some(let config), .some(let userId)):
                    self = .configured(config: config, userId: userId)
                default:
                    return
            }
        }
    }

    private var state: State = .startup() {
        didSet {
            goToScreenFor(newState: state, oldState: oldValue)
        }
    }

    private var appSettings: AppSettings = .init()

    override init(services: ServicesFactory) {
        self.settingsRepository = services.makeSettingsRepository()
        super.init(services: services)
    }

    func start() {
        appSettings.loadFromDefaults(settingsRepository)
        state.loadFromDefaults(settingsRepository)

        guard Config.logLevel != .off else { return }
        logService.startLogging()
    }

    private func goToScreenFor(newState: State, oldState: State) {
        switch newState {
            case .startup(let config):
                goToSetup(config: config, allowReconfiguration: true, direction: .forward)
            case .userChange(config: let config):
                goToSetup(config: config, allowReconfiguration: false, direction: .reverse)
            case .configured(config: let config, userId: let userId):
                goToHome(session: .init(config: config, user: Contact.makeRandomContact(alias: userId), addressBook: services.makeAddressBook(config: config)))
        }
    }

    private func goToSetup(config: Config?, allowReconfiguration: Bool, direction: UIPageViewController.NavigationDirection) {
        let coordinator = AppSetupCoordinator(stage: config.setupStage, allowReconfiguration: allowReconfiguration, appSettings: appSettings, services: services)
        addChild(coordinator)
        coordinator.start { [weak self] session in
            guard let self else { return }

            self.removeChild(coordinator)
            do {
                try self.settingsRepository.store(session.config)
                self.settingsRepository.store(loggedUser: session.user.alias)
                self.state = .configured(config: session.config, userId: session.user.alias)
            } catch {
                self.state = .startup(config: config)
            }
        }
        pageController.setViewControllers([coordinator.controller], direction: direction, animated: true)
    }

    private func goToHome(session: UserSession) {
        let coordinator = MainCoordinator(session: session, appSettings: appSettings, services: services)
        coordinator.onLogout = { [weak self] in
            guard let self else { return }

            self.removeChild(coordinator)
            self.settingsRepository.store(loggedUser: nil)
            self.state = .userChange(config: session.config)
        }
        coordinator.onReset = { [weak self] in
            guard let self else { return }

            self.removeChild(coordinator)
            self.settingsRepository.reset()
            self.state = .startup(config: session.config)
        }

        addChild(coordinator)
        coordinator.start()
        pageController.setViewControllers([coordinator.tabBarController], direction: .forward, animated: true)
    }

    override func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool {
        guard event == .shareLogFiles else {
            return super.handle(event: event, direction: direction)
        }

        shareLogs()
        return true
    }

    // MARK: - Log

    func shareLogs() {
        guard MFMailComposeViewController.canSendMail() else {
            showGenericErrorAlert()
            return
        }

        guard !logService.logFileList.isEmpty else {
            showNoLogFilePresentErrorAlert()
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([Strings.Logs.Mail.recipient])
        composer.setSubject(Strings.Logs.Mail.subject)
        composer.setMessageBody(Strings.Logs.Mail.body, isHTML: false)

        attachLogFilesToComposer(composer)

        pageController.present(composer, animated: true)
    }

    private func attachLogFilesToComposer(_ composer: MFMailComposeViewController) {
        logService.logFileList.forEach { logFileUrl in
            guard let fileData = try? Data(contentsOf: logFileUrl) else { return }

            composer.addAttachmentData(fileData, mimeType: "text/txt", fileName: logFileUrl.lastPathComponent)
        }
    }

    private func showGenericErrorAlert() {
        pageController.presentAlert(.shareFailed())
    }
    private func showNoLogFilePresentErrorAlert() {
        pageController.presentAlert(.logsNotFound())
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension RootCoordinator: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

private extension Optional where Wrapped == Config {

    var setupStage: AppSetupCoordinator.Stage {
        switch self {
            case .none:
                .configuration
            case .some(let config):
                .userSelection(config: config)
        }
    }
}

private extension UIAlertController {

    static func shareFailed() -> UIAlertController {
        let alert = UIAlertController.alert(title: Strings.Logs.Alert.title, message: Strings.Logs.Alert.sharingFailedMessage)
        alert.addAction(.cancel(title: Strings.Logs.Alert.cancel))
        return alert
    }

    static func logsNotFound() -> UIAlertController {
        let alert = UIAlertController.alert(title: Strings.Logs.Alert.title, message: Strings.Logs.Alert.noLogsMessage)
        alert.addAction(.cancel(title: Strings.Logs.Alert.cancel))
        return alert
    }
}
