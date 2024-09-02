// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

protocol TableViewSection {

    func registerReusableCells(_ tableView: UITableView)
    func numberOfRows() -> Int
    func titleForHeader(_ tableView: UITableView) -> String?
    func titleForFooter(_ tableView: UITableView) -> String?
    func cellForRowAt(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell
    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView)
}

extension TableViewSection {

    func registerReusableCells(_ tableView: UITableView) {}
    func titleForHeader(_ tableView: UITableView) -> String? { nil }
    func titleForFooter(_ tableView: UITableView) -> String? { nil }
    func didSelectRowAt(indexPath: IndexPath, tableView: UITableView) {}
}
