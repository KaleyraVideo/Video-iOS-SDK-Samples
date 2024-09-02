// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class AdvancedSettingsViewModel {

    var toolsConfig: Config.Tools
    var voipConfig: Config.VoIP
    var disableDirectIncomingCalls: Bool
    var showsUserInfo: Bool

    init(toolsConfig: Config.Tools = .default,
         voipConfig: Config.VoIP = .default,
         disableDirectIncomingCalls: Bool = false,
         showUserInfo: Bool = true) {
        self.toolsConfig = toolsConfig
        self.voipConfig = voipConfig
        self.disableDirectIncomingCalls = disableDirectIncomingCalls
        self.showsUserInfo = showUserInfo
    }
}

class AdvancedSettingsSetupViewController: UITableViewController {

    private var dataSource: DataSource

    // MARK: - Init

    init(model: AdvancedSettingsViewModel) {
        dataSource = DataSource.makeDataSource(for: model)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - View loading

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.registerReusableCells(tableView)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.tableView(tableView, didSelectRowAt: indexPath)
    }

}

private class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].didSelectRowAt(indexPath: indexPath, tableView: tableView)
    }

    static func makeDataSource(for model: AdvancedSettingsViewModel) -> DataSource {
        .init(sections: [
            ToolsSection(config: model.toolsConfig, onChange: { newConfig in model.toolsConfig = newConfig}),
            VoipSection(config: model.voipConfig, disableDirectIncomingCalls: model.disableDirectIncomingCalls, onChange: { newConfig, disableDirectIncomingCalls in
                model.voipConfig = newConfig
                model.disableDirectIncomingCalls = disableDirectIncomingCalls
            }),
            UserDetailsSection(header: Strings.Setup.UserDetailsSection.title, value: model.showsUserInfo, onChange: { showsUserInfo in
                model.showsUserInfo = showsUserInfo
            })
        ])
    }
}
