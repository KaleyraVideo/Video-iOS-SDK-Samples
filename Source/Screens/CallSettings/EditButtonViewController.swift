// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class EditButtonViewController: UIViewController, UITableViewDelegate {

    private enum SectionType: Int {
        case properties = 0
        case appearance
        case accessibility
        case action
    }

    private lazy var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preview)
        return view
    }()

    private lazy var preview: UIButton = {
        var config = UIButton.Configuration.bottomSheetButton()
        config.image = button.icon ?? Icons.questionMark
        config.title = button.title
        config.background.customView = ImageTrackingButtonBackgroundView()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.registerReusableCell(TextFieldTableViewCell.self)
        table.registerReusableCell(SwitchTableViewCell.self)
        table.registerReusableCell(UITableViewCell.self)
        table.registerReusableCell(ColorTableViewCell.self)
        return table
    }()

    private var button: CustomButton = .init() {
        didSet {
            updatePreview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit button"
        view.backgroundColor = .systemBackground
        setupHierarchy()
        setupConstraints()
        updatePreview()
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
            preview.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            preview.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            preview.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            preview.widthAnchor.constraint(greaterThanOrEqualToConstant: 46),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updatePreview() {
        var config = preview.configuration
        config?.title = button.title
        config?.image = button.icon ?? Icons.questionMark
        let tintColor = button.tint
        config?.titleTextAttributesTransformer = .init({ [tintColor] _ in
                .init([.font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12)),
                       .foregroundColor : tintColor ?? UIColor(rgb: 0x1B1B1B)])
        })
        config?.background.customView?.backgroundColor = button.background
        preview.tintColor = button.tint
        preview.isEnabled = button.isEnabled
        preview.configuration = config
        preview.accessibilityLabel = button.accessibilityLabel
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
            case .action: 3
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
                        cell.onTextChanged = { [weak self] title in
                            self?.button.title = title
                        }
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
                        cell.onSwitchValueChange = { [weak self] cell in
                            self?.button.isEnabled = cell.isOn
                        }
                        return cell
                    default:
                        fatalError()
                }
            case .appearance:
                switch indexPath.item {
                    case 0:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Tint color"
                        cell.color = button.tint
                        cell.onColorChanged = { [weak self] color in
                            self?.button.tint = color
                        }
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Background color"
                        cell.color = button.background
                        cell.onColorChanged = { [weak self] color in
                            self?.button.background = color
                        }
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
                        cell.onTextChanged = { [weak self] label in
                            self?.button.accessibilityLabel = label
                        }
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
                    case 2:
                        let cell = tableView.dequeueReusableCell(UITableViewCell.self, for: indexPath)
                        var content = UIListContentConfiguration.cell()
                        content.text = "None"
                        cell.contentConfiguration = content
                        cell.accessoryType = button.action == nil ? .checkmark : .none
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard SectionType(rawValue: indexPath.section) == .action else { return }

        switch indexPath.item {
            case 0:
                button.action = .openMaps
            case 1:
                button.action = .openURL
            case 2:
                button.action = nil
            default:
                return
        }
        tableView.reloadSections(.init(integer: SectionType.action.rawValue), with: .automatic)
    }
}
