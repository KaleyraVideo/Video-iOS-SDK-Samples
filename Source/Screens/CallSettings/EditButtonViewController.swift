// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class EditButtonViewController: UIViewController {

    private enum SectionType: Int {
        case properties = 0
        case appearance
        case accessibility
        case action
    }

    private lazy var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonPreview)
        return view
    }()

    private lazy var buttonPreview: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.registerReusableCell(TextFieldTableViewCell.self)
        table.registerReusableCell(SwitchTableViewCell.self)
        table.registerReusableCell(UITableViewCell.self)
        table.registerReusableCell(ColorTableViewCell.self)
        return table
    }()

    private var button: CustomButton = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        view.addSubview(header)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            header.heightAnchor.constraint(equalToConstant: 100),
            buttonPreview.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            buttonPreview.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

@available(iOS 15.0, *)
extension EditButtonViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType(rawValue: section) {
            case .properties: 3
            case .appearance: 2
            case .accessibility: 1
            case .action: 2
            default: 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SectionType(rawValue: indexPath.section) {
            case .properties:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
                        cell.placeholder = "Title"
                        cell.text = button.title
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Icon"
                        cell.contentConfiguration = content
                        cell.accessoryView = UIImageView(image: button.icon ?? Icons.questionMark)
                        return cell
                    case 2:
                        let cell = tableView.dequeueReusableCell(SwitchTableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Enabled"
                        cell.isOn = button.isEnabled
                        cell.contentConfiguration = content
                        return cell
                    default:
                        fatalError()
                }
            case .appearance:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Tint color"
                        cell.color = button.appearance?.tintColor
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Background color"
                        cell.color = button.appearance?.backgroundColor
                        return cell
                    default:
                        fatalError()
                }
            case .accessibility:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
                        cell.placeholder = "Accessibility label"
                        cell.text = button.accessibilityLabel
                        return cell
                    default:
                        fatalError()
                }
            case .action:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Open maps"
                        cell.contentConfiguration = content
                        cell.accessoryType = button.action == .openMaps ? .checkmark : .none
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Open Link"
                        cell.contentConfiguration = content
                        cell.accessoryType = button.action == .openURL ? .checkmark : .none
                        return cell
                    default:
                        fatalError()
                }
            default:
                fatalError()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch SectionType(rawValue: section) {
            case .properties: "Properties"
            case .appearance: "Appearance"
            case .accessibility: "Accessibility"
            case .action: "Action"
            default: nil
        }
    }
}
