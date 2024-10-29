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

    private enum StyleRow: Int, CaseIterable {
        case light
        case dark

        init?(indexPath: IndexPath) {
            self.init(rawValue: indexPath.row)
        }
    }

    private enum FontRow: Int, CaseIterable {
        case regular
        case medium

        init?(indexPath: IndexPath) {
            self.init(rawValue: indexPath.row)
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
        switch Section(indexPath: indexPath) {
            case .logo:
                let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                let lightURL: String?
                let darkURL: String?

                switch theme?.logo {
                    case .some(let logo):
                        lightURL = logo.image.light.absoluteString
                        darkURL = logo.image.dark.absoluteString
                    case nil:
                        lightURL = nil
                        darkURL = nil
                }

                switch StyleRow(indexPath: indexPath) {
                    case .light:
                        cell.text = lightURL
                        cell.placeholder = "Light logo"
                        cell.onTextChanged = { [weak self] text in
                            self?.onLightLogoChanged(url: .init(string: text ?? ""))
                        }
                    case .dark:
                        cell.text = darkURL
                        cell.placeholder = "Dark logo"
                        cell.onTextChanged = { [weak self] text in
                            self?.onDarkLogoChanged(url: .init(string: text ?? ""))
                        }
                    default:
                        break
                }

                return cell
            case .color:
                let cell: ColorTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                switch StyleRow(indexPath: indexPath) {
                    case .light:
                        cell.title = "Light"
                        cell.color = theme?.palette?.seed.resolvedLight
                        cell.onColorChanged = { [weak self] color in
                            self?.onLightColorChanged(color: color)
                        }
                    case .dark:
                        cell.title = "Dark"
                        cell.color = theme?.palette?.seed.resolvedDark
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
                switch FontRow(indexPath: indexPath) {
                    case .regular:
                        config.text = "Regular font"
                        font = theme?.typography?.regular
                    case .medium:
                        config.text = "Medium Font"
                        font = theme?.typography?.medium
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

    // MARK: - Logo

    private func onLightLogoChanged(url: URL?) {
        let newLogo: KaleyraVideoSDK.Theme.Logo?

        switch theme?.logo {
            case .some(let logo) where logo.image.light != logo.image.dark :
                if let url {
                    newLogo = .init(image: .init(light: url, dark: logo.image.dark))
                } else {
                    newLogo = .init(image: .init(url: logo.image.dark))
                }
            default:
                if let url {
                    newLogo = .init(image: .init(url: url))
                } else {
                    newLogo = nil
                }
        }
        theme?.logo = newLogo
    }

    private func onDarkLogoChanged(url: URL?) {
        let newLogo: KaleyraVideoSDK.Theme.Logo?

        switch theme?.logo {
            case .some(let logo) where logo.image.light != logo.image.dark :
                if let url {
                    newLogo = .init(image: .init(light: logo.image.light, dark: url))
                } else {
                    newLogo = .init(image: .init(url: logo.image.dark))
                }
            default:
                if let url {
                    newLogo = .init(image: .init(url: url))
                } else {
                    newLogo = nil
                }
        }
        theme?.logo = newLogo
    }

    // MARK: - Color

    private func onLightColorChanged(color: UIColor?) {
        let seed: UIColor?

        switch (theme?.palette?.seed.resolvedLight, theme?.palette?.seed.resolvedDark) {
            case (_, nil):
                seed = color
            case (_, .some(let dark)):
                if let color {
                    seed = .init(light: color, dark: dark)
                } else {
                    seed = dark
                }
        }
        theme?.palette = seed.map{ .init(seed: $0) }
        tableView.reloadSections(.init(integer: Section.color.rawValue), with: .automatic)
    }

    private func onDarkColorChanged(color: UIColor?) {
        let seed: UIColor?

        switch (theme?.palette?.seed.resolvedLight, theme?.palette?.seed.resolvedDark) {
            case (nil, _):
                seed = color
            case (.some(let light), _):
                if let color {
                    seed = .init(light: light, dark: color)
                } else {
                    seed = light
                }
        }
        theme?.palette = seed.map{ .init(seed: $0) }
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
            if theme?.typography == nil {
                theme?.typography = .init(regular: font, medium: font)
            }
            switch indexForFontPicker {
                case 0:
                    theme?.typography?.regular = font
                case 1:
                    theme?.typography?.medium = font
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
