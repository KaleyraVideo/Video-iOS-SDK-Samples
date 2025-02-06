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
        view.layoutMargins.left = 12
        view.layoutMargins.right = 12
        return view
    }()

    private lazy var horizontalPreview: BadgedButton = {
        var config = UIButton.Configuration.bottomSheetHorizontalButton()
        config.image = button.icon
        config.title = button.title ?? "Title"
        let button = BadgedButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
        return button
    }()

    private lazy var verticalPreview: BadgedButton = {
        var config = UIButton.Configuration.bottomSheetVerticalButton()
        config.image = button.icon
        config.title = button.title ?? "Title"
        config.background.customView = ImageTrackingButtonBackgroundView()
        let button = BadgedButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
        return button
    }()

    private lazy var preview: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [verticalPreview, horizontalPreview])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 25
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)
        stack.backgroundColor = Theme.Color.bottomSheetBackground
        stack.layer.masksToBounds = true
        stack.layer.cornerRadius = 22
        return stack
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

    private var button: Button.Custom {
        didSet {
            updatePreviews()
            guard let index = settings.customButtons.firstIndex(where: { $0.identifier == button.identifier }) else {
                settings.customButtons.append(button)
                return
            }
            settings.customButtons[index] = button
        }
    }

    private let settings: AppSettings

    init(settings: AppSettings, button: Button.Custom) {
        self.settings = settings
        self.button = button
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit button"
        view.backgroundColor = .systemBackground
        setupHierarchy()
        setupConstraints()
        updatePreviews()
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
            preview.leftAnchor.constraint(equalTo: header.layoutMarginsGuide.leftAnchor),
            preview.rightAnchor.constraint(equalTo: header.layoutMarginsGuide.rightAnchor),
            preview.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            preview.heightAnchor.constraint(equalToConstant: 95),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updatePreviews() {
        updateVerticalPreview()
        updateHorizontalPreview()
    }

    private func updateVerticalPreview() {
        var config = verticalPreview.configuration
        config?.title = button.title ?? "Title"
        config?.image = button.icon
        config?.titleTextAttributesTransformer = .init({ _ in
            .init([.font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12)),
                   .foregroundColor : Theme.Color.defaultButtonTint])
        })
        config?.background.customView?.backgroundColor = button.background
        verticalPreview.tintColor = button.tint
        verticalPreview.isEnabled = button.isEnabled
        verticalPreview.configuration = config
        verticalPreview.accessibilityLabel = button.accessibilityLabel
        verticalPreview.badgeValue = button.badge
    }

    private func updateHorizontalPreview() {
        var config = horizontalPreview.configuration
        config?.title = button.title ?? "Title"
        config?.image = button.icon
        let tintColor = button.tint
        config?.titleTextAttributesTransformer = .init({ [tintColor] _ in
            .init([.font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 14)),
                   .foregroundColor : tintColor as Any])
        })
        config?.background.backgroundColor = button.background
        horizontalPreview.tintColor = button.tint
        horizontalPreview.isEnabled = button.isEnabled
        horizontalPreview.configuration = config
        horizontalPreview.accessibilityLabel = button.accessibilityLabel
        horizontalPreview.badgeValue = button.badge
    }
}

@available(iOS 15.0, *)
extension EditButtonViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType(rawValue: section) {
            case .properties: 4
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
                        let imageView = UIImageView(image: button.icon)
                        imageView.tintColor = .label
                        cell.accessoryView = imageView
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
                    case 3:
                        let cell = tableView.dequeueReusableCell(TextFieldTableViewCell.self, for: indexPath)
                        cell.placeholder = "Badge"
                        cell.text = button.badge.map({ "\($0)" })
                        cell.keyboardType = .numberPad
                        cell.onTextChanged = { [weak self] title in
                            self?.button.badge = title.map({ UInt($0) }) ?? nil
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
                        cell.pickerTitle = "Tint color"
                        cell.onColorChanged = { [weak self] color in
                            self?.button.tint = color
                        }
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(ColorTableViewCell.self, for: indexPath)
                        cell.title = "Background color"
                        cell.color = button.background
                        cell.pickerTitle = "Background color"
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
        guard let section = SectionType(rawValue: indexPath.section) else { return }

        switch section {
            case .properties:
                guard indexPath.item == 1 else { return }
                let picker = SymbolPickerViewController()
                let controller = UINavigationController(rootViewController: picker)
                picker.onSymbolSelected = { [weak self] symbol in
                    self?.button.symbol = symbol
                    self?.tableView.reloadRows(at: [.init(row: 1, section: 0)], with: .automatic)
                    self?.dismiss(animated: true)
                }
                present(controller, animated: true)
            case .action:
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
                tableView.reloadSections(.init(integer: section.rawValue), with: .automatic)
            default:
                return
        }
    }
}
