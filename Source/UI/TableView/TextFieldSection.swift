// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class TextFieldSection: TableViewSection {

    private let header: String
    private var value: String {
        didSet {
            guard value != oldValue else { return }

            onChange(value)
        }
    }
    private let footer: String?
    private let onChange: (String) -> Void

    init(header: String, value: String, footer: String? = nil, onChange: @escaping (String) -> Void) {
        self.header = header
        self.value = value
        self.footer = footer
        self.onChange = onChange
    }

    func registerReusableCells(_ tableView: UITableView) {
        tableView.registerReusableCell(TextFieldTableViewCell.self)
    }

    func numberOfRows() -> Int {
        1
    }

    func titleForHeader(_ tableView: UITableView) -> String? {
        header
    }

    func titleForFooter(_ tableView: UITableView) -> String? {
        footer
    }

    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.text = value
        cell.onTextChanged = { [weak self] text in
            self?.value = text ?? ""
        }
        return cell
    }

    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {}
}
