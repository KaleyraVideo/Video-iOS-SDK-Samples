// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class DisclosureRow: ConfigurableSection.Row {

    let title: String
    let onSelect: (() -> Void)?

    init(title: String, onSelect: (() -> Void)?) {
        self.title = title
        self.onSelect = onSelect
    }

    func registerReusableCell(tableView: UITableView) {
        tableView.registerReusableCell(UITableViewCell.self)
    }

    func cellForRow(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.cell()
            content.text = title
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
        }

        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func didSelectRow(tableView: UITableView) {
        onSelect?()
    }
}
