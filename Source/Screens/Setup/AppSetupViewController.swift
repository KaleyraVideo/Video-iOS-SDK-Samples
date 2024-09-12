// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

class AppSetupViewModel {

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
    var toolsConfig: Config.Tools
    var voipConfig: Config.VoIP
    var disableDirectIncomingCalls: Bool

    var isValid: Bool { keys.areValid }

    init(keys: Keys = .empty,
         environment: Config.Environment = .sandbox,
         region: Config.Region = .europe,
         toolsConfig: Config.Tools = .default,
         voipConfig: Config.VoIP = .default,
         disableDirectIncomingCalls: Bool = false,
         showsUserInfo: Bool = true) {
        self.keys = keys
        self.environment = environment
        self.region = region
        self.toolsConfig = toolsConfig
        self.voipConfig = voipConfig
        self.disableDirectIncomingCalls = disableDirectIncomingCalls
        self.showsUserInfo = showsUserInfo
    }

    convenience init(config: Config?) {
        guard let conf = config else { self.init();  return }
        self.init(keys: .init(keys: conf.keys),
                  environment: conf.environment,
                  region: conf.region,
                  toolsConfig: conf.tools,
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
              voip: voipConfig,
              tools: toolsConfig)
    }
}

class AppSetupViewController: UITableViewController {

    private var model: AppSetupViewModel
    private var dataSource: DataSource
    private var tableViewFont: UIFont = UIFont.systemFont(ofSize: 20)
    private var tableViewAccessoryFont: UIFont = UIFont.systemFont(ofSize: 18)

    var onDismiss: ((Config) -> Void)?

#if SAMPLE_CUSTOMIZABLE_THEME

    private var themeStorage: ThemeStorage
#endif

    init(model: AppSetupViewModel, services: ServicesFactory) {
        self.model = model
        self.dataSource = DataSource.makeDataSource(for: model)
#if SAMPLE_CUSTOMIZABLE_THEME
        self.themeStorage = services.makeThemeStorage()
#endif
        super.init(style: .insetGrouped)
    }


    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.Setup.title
        setupTableViewContentInset()
        registerCells()
        setupTableViewFooter()
#if SAMPLE_CUSTOMIZABLE_THEME
        themeChanged(theme: themeStorage.getSelectedTheme())
#endif
    }

    private func setupTableViewContentInset() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    private func registerCells() {
        dataSource.registerReusableCells(tableView)
    }

    private func setupTableViewFooter() {
        let footer = ButtonTableFooter(frame: .init(x: 0, y: 0, width: 150, height: 50))
        footer.buttonTitle = Strings.Setup.confirm
        footer.buttonAction = { [weak self] in
            guard let self = self else { return }

            self.onConfirmButtonTouched()
        }

        tableView.tableFooterView = footer
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.numberOfSections(in: tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource.tableView(tableView, titleForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        dataSource.tableView(tableView, titleForFooterInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.tableView(tableView, didSelectRowAt: indexPath)
    }
}

#if SAMPLE_CUSTOMIZABLE_THEME

extension AppSetupViewController: Themable {

    func themeChanged(theme: AppTheme) {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        tableViewFont = theme.font?.toUIFont() ?? UIFont.systemFont(ofSize: 20)
        tableViewAccessoryFont = theme.secondaryFont?.toUIFont() ?? UIFont.systemFont(ofSize: 18)
        view.subviews.forEach { subview in
            subview.tintColor = theme.accentColor.toUIColor()
        }

        tableView.reloadData()
    }
}

#endif

private final class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let sections: [TableViewSection]

    init(sections: [TableViewSection]) {
        self.sections = sections
    }

    func registerReusableCells(_ tableView: UITableView) {
        sections.forEach({ $0.registerReusableCells(tableView) })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        sections[indexPath.section].cellForRowAt(indexPath: indexPath, tableView: tableView)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].titleForHeader(tableView)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].titleForFooter(tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].didSelectRowAt(indexPath: indexPath, tableView: tableView)
    }

    static func makeDataSource(for model: AppSetupViewModel) -> DataSource {
        .init(sections: [
            SingleChoiceTableViewSection(header: Strings.Setup.RegionSection.title, options: Config.Region.allCases, selected: model.region, optionName: RegionPresenter.localizedName, onChange: { newRegion in model.region = newRegion }),
            SingleChoiceTableViewSection(header: Strings.Setup.EnvironmentSection.title, options: Config.Environment.allCases, selected: model.environment, optionName: EnvironmentPresenter.localizedName, onChange: { newEnv in model.environment = newEnv }),
            SecretKeySection(header: Strings.Setup.AppIdSection.title, key: model.keys.appId, footer: Strings.Setup.AppIdSection.footer, onChange: { key in model.keys.appId = key }),
            SecretKeySection(header: Strings.Setup.ApiKeySection.title, key: model.keys.apiKey, footer: Strings.Setup.ApiKeySection.footer, onChange: { key in model.keys.apiKey = key }),
            UserDetailsSection(header: Strings.Setup.UserDetailsSection.title, value: model.showsUserInfo, onChange: { showsUserInfo in model.showsUserInfo = showsUserInfo }),
            ToolsSection(config: model.toolsConfig, onChange: { newConfig in model.toolsConfig = newConfig }),
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
