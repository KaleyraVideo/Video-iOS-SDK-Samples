// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class EditButtonViewController: UIViewController {

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
        switch section {
            case 0: 3
            case 1: 2
            case 2: 1
            case 3: 2
            default: 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section

        switch section {
            case 0:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
                        cell.placeholder = "Title"
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Icon"
                        cell.contentConfiguration = content
                        cell.accessoryView = UIImageView(image: Icons.questionMark)
                        return cell
                    case 2:
                        let cell = tableView.dequeueReusableCell(SwitchTableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Enabled"
                        cell.contentConfiguration = content
                        return cell
                    default:
                        fatalError()
                }
            case 1:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Tint color"
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Background color"
                        return cell
                    default:
                        fatalError()
                }
            case 2:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
                        cell.placeholder = "Accessibility label"
                        return cell
                    default:
                        fatalError()
                }
            case 3:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Open maps"
                        cell.contentConfiguration = content
                        cell.accessoryType = .checkmark
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "Open Link"
                        cell.contentConfiguration = content
                        cell.accessoryType = .checkmark
                        return cell
                    default:
                        fatalError()
                }
            default:
                fatalError()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                "Properties"
            case 1:
                "Appearance"
            case 2:
                "Accessibility"
            case 3:
                "Action"
            default:
                nil
        }
    }
}
