// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class VoipSection: TableViewSection {

    private(set) var config: Config.VoIP {
        didSet {
            guard config != oldValue else { return }

            onChange(config, disableDirectIncomingCalls)
        }
    }

    private(set) var disableDirectIncomingCalls: Bool {
        didSet {
            guard disableDirectIncomingCalls != oldValue else { return }

            onChange(config, disableDirectIncomingCalls)
        }
    }

    private let onChange: (Config.VoIP, Bool) -> Void

    init(config: Config.VoIP, disableDirectIncomingCalls: Bool, onChange: @escaping (Config.VoIP, Bool) -> Void) {
        self.config = config
        self.disableDirectIncomingCalls = disableDirectIncomingCalls
        self.onChange = onChange
    }

    func registerReusableCells(_ tableView: UITableView) {
        tableView.registerReusableCell(ExpandableTableViewCell.self)
        tableView.registerReusableCell(SwitchTableViewCell.self)
    }

    func numberOfRows() -> Int {
        4
    }

    func titleForHeader(_ tableView: UITableView) -> String? {
        Strings.Setup.VoIPSection.title
    }

    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let cell: ExpandableTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.title = Strings.Setup.VoIPSection.automatic
                cell.accessoryType = config.isAutomatic ? .checkmark : .none
                config.isAutomatic ? cell.expand() : cell.collapse()
                let contentView = LabelWithSwitchView(text: Strings.Setup.VoIPSection.notificationsInForeground,
                                                      isOn: config.shouldListenForNotificationsInForeground)
                contentView.onValueChange = { [weak self] listenInForeground in
                    self?.config = .automatic(strategy: listenInForeground ? .always : .backgroundOnly)
                }
                cell.expandedContent = contentView
                return cell
            case 1:
                let cell: ExpandableTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.title = Strings.Setup.VoIPSection.manual
                cell.accessoryType = config.isManual ? .checkmark : .none
                config.isManual ? cell.expand() : cell.collapse()
                let contentView = LabelWithSwitchView(text: Strings.Setup.VoIPSection.notificationsInForeground,
                                                      isOn: config.shouldListenForNotificationsInForeground)
                contentView.onValueChange = { [weak self] listenInForeground in
                    self?.config = .manual(strategy: listenInForeground ? .always : .backgroundOnly)
                }
                cell.expandedContent = contentView
                return cell
            case 2:
                let cell = UITableViewCell()
                cell.textLabel?.text = Strings.Setup.VoIPSection.disabled
                cell.accessoryType = config.isDisabled ? .checkmark : .none
                return cell
            case 3:
                let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = Strings.Setup.VoIPSection.disableDirectIncomingCalls
                cell.isOn = disableDirectIncomingCalls
                cell.onSwitchValueChange = { [weak self] cell in
                    self?.disableDirectIncomingCalls = cell.isOn
                }
                return cell
            default:
                fatalError()
        }
    }

    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {
        guard let newConfig = Config.VoIP(row: indexPath.row) else { return }

        switch (newConfig, config) {
            case (.automatic, .automatic):
                return
            case (.manual, .manual):
                return
            case (.disabled, .disabled):
                return
            default:
                break
        }

        config = newConfig
        tableView.reloadSections(.init(integer: indexPath.section), with: .automatic)
    }
}

private extension Config.VoIP {

    init?(row: Int) {
        switch row {
            case 0:
                self = .automatic(strategy: .backgroundOnly)
            case 1:
                self = .manual(strategy: .backgroundOnly)
            case 2:
                self = .disabled
            default:
                return nil
        }
    }
}
