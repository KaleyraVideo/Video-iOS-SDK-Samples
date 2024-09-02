// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import Foundation
import UIKit
import KaleyraVideoSDK

private struct AlertAction {
    let name: String
    let handler: () -> Void
}

class CustomThemeViewController : UIViewController {

    private let colorCellIdentifier = "colorCellIdentifier"
    private let detailCellIdentifier = "detailCellIdentifier"

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ColorTableViewCell.self, forCellReuseIdentifier: colorCellIdentifier)
        return tableView
    }()

    private var tableViewFont: UIFont = UIFont.systemFont(ofSize: 20)
    private var tableViewAccessoryFont: UIFont = UIFont.systemFont(ofSize: 18)

    var viewModel: CustomThemeViewModelProtocol?

    var pickerFactory : PickerFactory?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTheme()
    }

    fileprivate func setUpUI() {
        view.backgroundColor = .white
        navigationItem.title = Strings.Settings.customTheme

        view.insertSubview(tableView, at: 0)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }

    func setUpTheme() {
        guard let viewModel = viewModel else {
            return
        }

        themeChanged(theme: viewModel.selectedTheme)
    }
}

extension CustomThemeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = viewModel?.dataSource[indexPath.item] else { return UITableViewCell() }
        let cell: UITableViewCell

        switch model.type {
        case .color:
            cell = tableView.dequeueReusableCell(withIdentifier: colorCellIdentifier, for: indexPath)
        default:
            cell = dequeueDetailCell(tableView)
        }

        self.configureCellWith(model: model, in: cell)

        model.valueChanged.append { [weak cell] value in
            guard let cellChanged = cell else { return }
            self.configureCellWith(model: model, in: cellChanged)
        }
        return cell
    }

    func configureCellWith(model: CustomThemeModel, in cell: UITableViewCell) {
        switch model.type {
        case .color:
            guard let colorCell = cell as? ColorTableViewCell else { return }
            colorCell.title = model.name
            colorCell.setUpLabelFont(font: tableViewFont)
            let color = model.value as? AppThemeColor
            colorCell.colorPreview.setUpColor(color?.toUIColor())
        default:
            cell.textLabel?.font = tableViewFont
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.font = tableViewAccessoryFont
            cell.detailTextLabel?.text = getDescriptionStringFor(value: model.value, to: cell)
        }
    }

    func getDescriptionStringFor(value: Any, to cell: UITableViewCell) -> String? {
        switch value {
            case is Bool:
                guard let val = value as? Bool else { return nil }
                return val.description
            case is AppThemeFont:
                guard let val = value as? AppThemeFont else { return nil }
                return val.fontName
            case is UIBarStyle:
                guard let val = value as? UIBarStyle else { return nil }
                return val.description
            case is UIKeyboardAppearance:
                guard let val = value as? UIKeyboardAppearance else { return nil }
                return val.description
            case is CGFloat:
                return String(describing: value)
            default:
                return "not selected"
        }
    }

    private func dequeueDetailCell(_ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier) else {
            return UITableViewCell(style: .value1, reuseIdentifier: detailCellIdentifier)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.dataSource.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = viewModel?.dataSource[indexPath.item] else { return }
        viewModel?.handleSelection(of: model)
    }
}

extension CustomThemeViewController : Themable {
    func themeChanged(theme: AppTheme) {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        tableViewFont = UIFont(name: theme.font?.fontName ?? "avenir", size: theme.font?.pointSize ?? 20)!
        tableViewAccessoryFont = UIFont(name: theme.secondaryFont?.fontName ?? "avenir", size: theme.secondaryFont?.pointSize ?? 18)!
        view.subviews.forEach { subview in
            subview.tintColor = theme.accentColor.toUIColor()
        }
        tableView.reloadData()
    }
}
#endif
