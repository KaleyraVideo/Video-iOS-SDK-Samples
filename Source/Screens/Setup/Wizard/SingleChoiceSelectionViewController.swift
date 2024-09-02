// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class SingleChoiceSelectionViewController<Option: Equatable> : UITableViewController {

    typealias Presenter = (Option) -> String

    private let options: [Option]
    private let localizedName: Presenter
    private var selectedOption: Option

    var onSelection: ((Option) -> Void)?

    init(options: [Option], presenter: @escaping Presenter) {
        precondition(!options.isEmpty)

        self.options = options
        self.localizedName = presenter
        self.selectedOption = options[0]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    // MARK: - Data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.accessoryType = selectedOption == option ? .checkmark : .none
        cell.textLabel?.text = localizedName(option)
        return cell
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = options[indexPath.row]
        tableView.reloadRows(at: [indexPath], with: .automatic)
        onSelection?(selectedOption)
    }
}
