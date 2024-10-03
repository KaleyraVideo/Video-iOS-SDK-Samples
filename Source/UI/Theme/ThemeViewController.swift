// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ThemeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.Settings.changeTheme
        tableView.registerReusableCell(ColorTableViewCell.self)
        tableView.registerReusableCell(TextFieldTableViewCell.self)
        tableView.registerReusableCell(UITableViewCell.self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                1
            case 1:
                2
            case 3:
                2
            default:
                0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row

        switch section {
            case 0:
                let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.onTextChanged = { _ in

                }
                return cell
            case 1:
                let cell: ColorTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.title = row == 0 ? "light" : "dark"
                return cell
            case 2:
                let cell: UITableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = row == 0 ? "Regular font" : "Medium Font"
                return cell
            default:
                fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                "Logo"
            case 1:
                "Colors"
            case 2:
                "Font"
            default:
                nil
        }
    }
}
