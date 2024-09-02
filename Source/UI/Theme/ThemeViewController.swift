// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import Foundation
import UIKit

class ThemeViewController : UIViewController, Themable {

    let themeTableViewCellIdentifier: String = "themeTableViewCell"
    var viewModel: ThemeViewModelProtocol?
    var theme: AppTheme
    private var cells: [ThemeCell] = []

    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(ThemeCell.self, forCellReuseIdentifier: themeTableViewCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private var sectionHeader: UITableViewHeaderFooterView?

    init(theme: AppTheme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }

    private func setup() {
        setupSelf()
        setupSubviews()
        setupConstraints()
        setUpTheme()
    }

    private func setUpTheme() {
        themeChanged(theme: theme)
    }

    private func setupSubviews() {
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSelf() {
        title = Strings.Settings.changeTheme
    }

    func themeChanged(theme: AppTheme) {
        self.theme = theme
        applyTheme()
    }

    private func applyTheme() {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        view.subviews.forEach { subview in
            subview.tintColor = theme.accentColor.toUIColor()
        }

        cells.forEach { cell in
            cell.themeChanged(theme: theme)
        }

        applyThemeToTableViewHeader()
    }

    private func applyThemeToTableViewHeader() {
        sectionHeader?.textLabel?.textColor = (view.backgroundColor?.isLight ?? true) ? .gray : .lightGray
    }
}

extension ThemeViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.datasource.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: themeTableViewCellIdentifier) as? ThemeCell,
                let model = viewModel?.datasource[indexPath.item] else {
            return UITableViewCell()
        }
        checkCell(cell: cell, for: model.selected)
        model.selectedChanged = { [weak self] value in
            self?.checkCell(cell: cell, for: value)
        }
        cell.textLabel?.text = model.name
        cell.themeChanged(theme: theme)

        if !cells.contains(cell) {
            cells.append(cell)
        }

        return cell
    }

    private func checkCell(cell: UITableViewCell, for value: Bool) {
        cell.accessoryType = value ? .checkmark : .none
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Strings.Settings.chooseTheme
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = viewModel?.datasource[indexPath.item] else { return }
        viewModel?.selectItem(theme: model)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            sectionHeader = header
        }

        applyThemeToTableViewHeader()
    }
}
#endif
