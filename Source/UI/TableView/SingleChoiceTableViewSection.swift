// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class SingleChoiceTableViewSection<Option: Equatable>: TableViewSection {

    let header: String
    let options: [Option]
    var selected: Option {
        didSet {
            guard selected != oldValue else { return }

            onChange(selected)
        }
    }
    let optionName: (Option) -> String
    let onChange: (Option) -> Void

    init(header: String, options: [Option], selected: Option, optionName: @escaping (Option) -> String, onChange: @escaping (Option) -> Void) {
        precondition(!options.isEmpty)
        precondition(options.contains(selected))
        self.header = header
        self.options = options
        self.selected = selected
        self.optionName = optionName
        self.onChange = onChange
    }

    func registerReusableCells(_ tableView: UITableView) {
        tableView.registerReusableCell(UITableViewCell.self)
    }

    func numberOfRows() -> Int {
        options.count
    }

    func titleForHeader(_ tableView: UITableView) -> String? {
        header
    }

    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath)
        let current = options[indexPath.row]
        cell.selectionStyle = .none
        cell.tintColor = Theme.Color.secondary
        cell.accessoryType = current == selected ? .checkmark : .none
        cell.textLabel?.text = optionName(current)
        return cell
    }

    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {
        let current = options[indexPath.row]
        guard current != selected else { return }

        selected = current

        tableView.reloadSections(.init(integer: indexPath.section), with: .automatic)
    }
}
