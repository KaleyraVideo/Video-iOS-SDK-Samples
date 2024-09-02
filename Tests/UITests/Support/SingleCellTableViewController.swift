// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

class SingleCellTableViewController: UITableViewController {

    typealias CellProvider = (UITableView, IndexPath) -> UITableViewCell

    private let cellProvider: CellProvider
    private let height: CGFloat

    init(cellProvider: @escaping CellProvider, height: CGFloat) {
        self.cellProvider = cellProvider
        self.height = height
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        tableView.rowHeight = height
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellProvider(tableView, indexPath)
    }
}
