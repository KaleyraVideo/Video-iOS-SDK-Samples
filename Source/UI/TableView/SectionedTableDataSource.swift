// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class SectionedTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let sections: [TableViewSection]

    init(sections: [TableViewSection]) {
        self.sections = sections
    }

    func registerReusableCells(_ tableView: UITableView) {
        sections.forEach({ $0.registerReusableCells(tableView) })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        sections[indexPath.section].cellForRowAt(indexPath: indexPath, tableView: tableView)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].titleForHeader(tableView)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].titleForFooter(tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].didSelectRowAt(indexPath: indexPath, tableView: tableView)
    }
}
