// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ConfigurableSection: TableViewSection {

    protocol Row {
        func registerReusableCell(tableView: UITableView)
        func cellForRow(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
        func didSelectRow(tableView: UITableView)
    }

    private let header: String?
    private let rows: [Row]
    private let footer: String?

    init(rows: [Row], header: String? = nil, footer: String? = nil) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }

    func numberOfRows() -> Int {
        rows.count
    }

    func registerReusableCells(_ tableView: UITableView) {
        rows.forEach {
            $0.registerReusableCell(tableView: tableView)
        }
    }

    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        rows[indexPath.row].cellForRow(tableView: tableView, at: indexPath)
    }

    func titleForHeader(_ tableView: UITableView) -> String? {
        header
    }

    func titleForFooter(_ tableView: UITableView) -> String? {
        footer
    }

    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {
        rows[indexPath.row].didSelectRow(tableView: tableView)
    }
}
