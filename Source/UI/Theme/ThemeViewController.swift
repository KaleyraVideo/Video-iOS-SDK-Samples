// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class ThemeViewController: UITableViewController, UIFontPickerViewControllerDelegate {

    private enum Section: Int, CaseIterable {
        case logo
        case color
        case font

        init?(indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)
        }

        var title: String {
            switch self {
                case .logo:
                    "Logo"
                case .color:
                    "Color"
                case .font:
                    "Font"
            }
        }
    }

    private let sdk: KaleyraVideo
    private var indexForFontPicker: Int?
    private var theme: KaleyraVideoSDK.Theme? {
        didSet {
            sdk.theme = theme
        }
    }

    init(sdk: KaleyraVideo) {
        self.sdk = sdk
        self.theme = sdk.theme ?? .init()
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.Settings.changeTheme
        tableView.registerReusableCell(ColorTableViewCell.self)
        tableView.registerReusableCell(TextFieldTableViewCell.self)
        tableView.registerReusableCell(UITableViewCell.self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)
        let row = indexPath.row

        switch section {
            case .logo:
                let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.onTextChanged = { _ in

                }
                return cell
            case .color:
                let cell: ColorTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                switch row {
                    case 0:
                        cell.title = "Light"
                        cell.color = theme?.paletteSeed?.resolvedLight
                        cell.onColorChanged = { [weak self] color in
                            self?.onLightColorChanged(color: color)
                        }
                    case 1:
                        cell.title = "Dark"
                        cell.color = theme?.paletteSeed?.resolvedDark
                        cell.onColorChanged = { [weak self] color in
                            self?.onDarkColorChanged(color: color)
                        }
                    default:
                        break
                }

                return cell
            case .font:
                let cell: UITableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.selectionStyle = .none

                let font: UIFont?
                var config = cell.defaultContentConfiguration()
                switch row {
                    case 0:
                        config.text = "Regular font"
                        font = theme?.regularFont
                    case 1:
                        config.text = "Medium Font"
                        font = theme?.mediumFont
                    default:
                        font = nil
                        break
                }
                config.secondaryText = font?.fontName ?? "N/A"

                if let font {
                    config.secondaryTextProperties.font = font
                }

                cell.contentConfiguration = config
                return cell
            case nil:
                fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(indexPath: indexPath) {
            case .font:
                presentFontPickerFor(row: indexPath.row)
            default:
                return
        }
    }

    // MARK: - Color

    private func onLightColorChanged(color: UIColor?) {
        let seed: UIColor?

        switch (theme?.paletteSeed?.resolvedLight, theme?.paletteSeed?.resolvedDark) {
            case (_, nil):
                seed = color
            case (_, .some(let dark)):
                if let color {
                    seed = .init(light: color, dark: dark)
                } else {
                    seed = dark
                }
        }
        theme?.paletteSeed = seed
        tableView.reloadSections(.init(integer: Section.color.rawValue), with: .automatic)
    }

    private func onDarkColorChanged(color: UIColor?) {
        let seed: UIColor?

        switch (theme?.paletteSeed?.resolvedLight, theme?.paletteSeed?.resolvedDark) {
            case (nil, _):
                seed = color
            case (.some(let light), _):
                if let color {
                    seed = .init(light: light, dark: color)
                } else {
                    seed = light
                }
        }
        theme?.paletteSeed = seed
        tableView.reloadSections(.init(integer: Section.color.rawValue), with: .automatic)
    }

    // MARK: - Font picker

    private func presentFontPickerFor(row: Int) {
        indexForFontPicker = row
        let config = UIFontPickerViewController.Configuration()
        config.includeFaces = true
        let controller = UIFontPickerViewController(configuration: config)
        controller.delegate = self
        present(controller, animated: true)
    }

    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let descriptor = viewController.selectedFontDescriptor {
            let font = UIFont(descriptor: descriptor, size: UIFont.systemFontSize)
            switch indexForFontPicker {
                case 0:
                    theme?.regularFont = font
                case 1:
                    theme?.mediumFont = font
                default:
                    break
            }
        }

        tableView.reloadSections(.init(integer: Section.font.rawValue), with: .automatic)

        fontPickerViewControllerDidCancel(viewController)
    }

    func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
        indexForFontPicker = nil
        viewController.dismiss(animated: true)
    }
}
