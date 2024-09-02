// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class UserDetailsSection: TableViewSection {

    let header: String

    private(set) var value: Bool {
        didSet {
            guard value != oldValue else { return }

            onChange(value)
        }
    }

    let onChange: (Bool) -> Void

    init(header: String, value: Bool, onChange: @escaping (Bool) -> Void) {
        self.header = header
        self.value = value
        self.onChange = onChange
    }

    func registerReusableCells(_ tableView: UITableView) {
        tableView.registerReusableCell(SwitchTableViewCell.self)
    }

    func numberOfRows() -> Int {
        1
    }

    func titleForHeader(_ tableView: UITableView) -> String? {
        header
    }

    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = Strings.Setup.UserDetailsSection.cellTitle
        cell.isOn = value
        cell.onSwitchValueChange = { [weak self] sender in
            self?.value = sender.isOn
        }
        return cell
    }

    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {}
}
