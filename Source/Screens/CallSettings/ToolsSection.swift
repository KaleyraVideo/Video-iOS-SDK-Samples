// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ToolsSection: TableViewSection {

    private(set) var config: CallSettings.Tools {
        didSet {
            guard config != oldValue else { return }

            onChange(config)
        }
    }

    private let onChange: (CallSettings.Tools) -> Void

    init(config: CallSettings.Tools, onChange: @escaping (CallSettings.Tools) -> Void) {
        self.config = config
        self.onChange = onChange
    }

    func registerReusableCells(_ tableView: UITableView) {
        tableView.registerReusableCell(SwitchTableViewCell.self)
    }

    func numberOfRows() -> Int {
        5
    }

    func titleForHeader(_ tableView: UITableView) -> String? {
        Strings.CallSettings.ToolsSection.title
    }

    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        switch indexPath.row {
            case 0:
                cell.textLabel?.text = Strings.CallSettings.ToolsSection.chat
                cell.onSwitchValueChange = { [weak self] sender in
                    self?.config.isChatEnabled = sender.isOn
                }
                cell.isOn = config.isChatEnabled
            case 1:
                cell.textLabel?.text = Strings.CallSettings.ToolsSection.whiteboard
                cell.onSwitchValueChange = { [weak self] sender in
                    self?.config.isWhiteboardEnabled = sender.isOn
                }
                cell.isOn = config.isWhiteboardEnabled
            case 2:
                cell.textLabel?.text = Strings.CallSettings.ToolsSection.fileshare
                cell.onSwitchValueChange = { [weak self] sender in
                    self?.config.isFileshareEnabled = sender.isOn
                }
                cell.isOn = config.isFileshareEnabled
            case 3:
                cell.textLabel?.text = Strings.CallSettings.ToolsSection.screenshare
                cell.onSwitchValueChange = { [weak self] sender in
                    self?.config.isScreenshareEnabled = sender.isOn
                }
                cell.isOn = config.isScreenshareEnabled
            case 4:
                cell.textLabel?.text = Strings.CallSettings.ToolsSection.broadcast
                cell.onSwitchValueChange = { [weak self] sender in
                    self?.config.isBroadcastEnabled = sender.isOn
                }
                cell.isOn = config.isBroadcastEnabled
            default:
                break
        }

        return cell
    }

    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {}
}
