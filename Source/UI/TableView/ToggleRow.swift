// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ToggleRow<Value>: ConfigurableSection.Row {

    private let title: String?
    private var value: Value
    private let keypath: WritableKeyPath<Value, Bool>
    private let onChange: ((Bool) -> Void)?

    init(title: String?, value: Value, keypath: WritableKeyPath<Value, Bool>, onChange: ((Bool) -> Void)?) {
        self.title = title
        self.value = value
        self.keypath = keypath
        self.onChange = onChange
    }

    func registerReusableCell(tableView: UITableView) {
        tableView.registerReusableCell(SwitchTableViewCell.self)
    }

    func cellForRow(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = title
        cell.isOn = value[keyPath: keypath]
        cell.onSwitchValueChange = { [weak self] sender in
            guard let self else { return }

            self.value[keyPath: self.keypath] = sender.isOn
            self.onChange?(sender.isOn)
        }
        return cell
    }

    func didSelectRow(tableView: UITableView) {}
}
