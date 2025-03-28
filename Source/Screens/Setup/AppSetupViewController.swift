// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class AppSetupViewController: UITableViewController {

    final class ViewModel {

        struct Keys {

            var appId: String
            var apiKey: String

            var areValid: Bool {
                let apiKey = try? Config.ApiKey(self.apiKey)
                let appId = try? Config.AppId(self.appId)

                return apiKey != nil && appId != nil
            }

            init(appId: String, apiKey: String) {
                self.appId = appId
                self.apiKey = apiKey
            }

            init(keys: Config.Keys) {
                self.init(appId: keys.appId.description, apiKey: keys.apiKey.description)
            }

            func makeConfigKeys() throws -> Config.Keys {
                do {
                    return .init(apiKey: try .init(apiKey), appId: try .init(appId))
                } catch {
                    return .init(apiKey: try .init(appId), appId: try .init(apiKey))
                }
            }

            static var empty: Keys { .init(appId: "", apiKey: "") }
        }

        var region: Config.Region
        var environment: Config.Environment
        var keys: Keys
        var showsUserInfo: Bool
        var voipConfig: Config.VoIP
        var disableDirectIncomingCalls: Bool

        var isValid: Bool { keys.areValid }

        init(keys: Keys = .empty,
             environment: Config.Environment = .sandbox,
             region: Config.Region = .europe,
             voipConfig: Config.VoIP = .default,
             disableDirectIncomingCalls: Bool = false,
             showsUserInfo: Bool = true) {
            self.keys = keys
            self.environment = environment
            self.region = region
            self.voipConfig = voipConfig
            self.disableDirectIncomingCalls = disableDirectIncomingCalls
            self.showsUserInfo = showsUserInfo
        }

        convenience init(config: Config?) {
            guard let conf = config else { self.init();  return }
            self.init(keys: .init(keys: conf.keys),
                      environment: conf.environment,
                      region: conf.region,
                      voipConfig: conf.voip,
                      disableDirectIncomingCalls: conf.disableDirectIncomingCalls,
                      showsUserInfo: conf.showUserInfo)
        }

        func makeConfig() throws -> Config {
            .init(keys: try keys.makeConfigKeys(),
                  showUserInfo: showsUserInfo,
                  environment: environment,
                  region: region,
                  disableDirectIncomingCalls: disableDirectIncomingCalls,
                  voip: voipConfig)
        }
    }

    private var model: ViewModel
    private var dataSource: SectionedTableDataSource

    var onDismiss: ((Config) -> Void)?

    init(model: ViewModel) {
        self.model = model
        self.dataSource = .create(for: model)
        super.init(style: .insetGrouped)
    }


    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.Setup.title
        setupTableView()
    }

    private func setupTableView() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        dataSource.registerReusableCells(tableView)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        setupTableViewFooter()
    }

    private func setupTableViewFooter() {
        tableView.tableFooterView = ButtonTableFooter(title: Strings.Setup.confirm) { [weak self] in
            self?.onConfirmButtonTouched()
        }
    }

    private func onConfirmButtonTouched() {
        do {
            let config = try model.makeConfig()
            onDismiss?(config)
        } catch {
            presentInvalidConfigurationAlert()
        }
    }

    private func presentInvalidConfigurationAlert() {
        presentAlert(.invalidConfigurationAlert())
    }
}

private extension SectionedTableDataSource {

    static func create(for model: AppSetupViewController.ViewModel) -> SectionedTableDataSource {
        .init(sections: [
            SingleChoiceTableViewSection(header: Strings.Setup.RegionSection.title, options: Config.Region.allCases, selected: model.region, optionName: RegionPresenter.localizedName, onChange: { newRegion in model.region = newRegion }),
            SingleChoiceTableViewSection(header: Strings.Setup.EnvironmentSection.title, options: Config.Environment.allCases, selected: model.environment, optionName: EnvironmentPresenter.localizedName, onChange: { newEnv in model.environment = newEnv }),
            TextFieldSection(header: Strings.Setup.AppIdSection.title, value: model.keys.appId, footer: Strings.Setup.AppIdSection.footer, onChange: { key in model.keys.appId = key }),
            TextFieldSection(header: Strings.Setup.ApiKeySection.title, value: model.keys.apiKey, footer: Strings.Setup.ApiKeySection.footer, onChange: { key in model.keys.apiKey = key }),
            ToggleSection(header: Strings.Setup.UserDetailsSection.title, description: Strings.Setup.UserDetailsSection.cellTitle, value: model.showsUserInfo, onChange: { showsUserInfo in model.showsUserInfo = showsUserInfo }),
            VoipSection(config: model.voipConfig, disableDirectIncomingCalls: model.disableDirectIncomingCalls, onChange: { newConfig, disableDirectIncomingCalls in
                model.voipConfig = newConfig
                model.disableDirectIncomingCalls = disableDirectIncomingCalls
            })
        ])
    }
}

private extension UIAlertController {

    static func invalidConfigurationAlert() -> UIAlertController {
        let alert = UIAlertController.alert(title: Strings.Setup.InvalidConfigAlert.title, message: Strings.Setup.InvalidConfigAlert.message)
        alert.addAction(.cancel(title: Strings.Setup.InvalidConfigAlert.cancelAction))
        return alert
    }
}
