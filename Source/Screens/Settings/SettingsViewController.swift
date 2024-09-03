// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

protocol SettingsViewControllerDelegate: AnyObject {

#if SAMPLE_CUSTOMIZABLE_THEME
    func settingsViewControllerDidOpenTheme()
#endif

    func settingsViewControllerDidLogout()
    func settingsViewControllerDidReset()
    func settingsViewControllerDidUpdateUser(contact: Contact)
}

final class SettingsViewController: UIViewController {

    var onReady: (() -> Void)?
    var shareLogsAction: (() -> Void)?

    weak var delegate: SettingsViewControllerDelegate?

    let config: Config
    let versions: Versions
    let store: UserDefaultsStore

    var user: Contact {
        didSet {
            guard let url = user.profileImageURL, url.isFileURL else { return }
            iconImage.image = UIImage(contentsOfFile: url.path)
        }
    }

    private lazy var dataset: SettingsDataset = {
        SettingsDatasetBuilder()
                .addSection({ section in
                                section.addUsernameItem(user.alias)
                                        .addEnvironmentItem(config.environment)
                                        .addRegionItem(config.region)
                                        .addAppVersionItem(versions.app.formattedValue())
                                        .addSDKVersionItem(versions.sdk.formattedValue())
                                        .addShareLogs(action: shareLogsAction) })
                .addSection({ section in
                    section.addThemeItem(action: { [weak self] in self?.presentThemeViewController() })
                            .addLogoutItem(action: { [weak self] in self?.delegate?.settingsViewControllerDidLogout() })
                            .addResetItem(action: { self.reset() })
                })
                .build()
    }()

    fileprivate lazy var tableDatasource: UITableViewDataSource = {
        SettingsTableDataSource(dataset: dataset)
    }()

    private lazy var tableDelegate: UITableViewDelegate = {
        SettingsTableDelegate(dataset: dataset) { [weak self] in
            self?.makeHeader()
        }
    }()

    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = tableDatasource
        tableView.delegate = tableDelegate
        return tableView
    }()

    private lazy var iconImage: CircleMaskedImageView = {
        let iconImage = CircleMaskedImageView(image: Icons.logo256)
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.contentMode = .scaleAspectFill
        iconImage.clipsToBounds = true
        iconImage.isUserInteractionEnabled = true
        let recognizer = UILongPressGestureRecognizer(target: self, action:  #selector(longPress))
        iconImage.addGestureRecognizer(recognizer)
        return iconImage
    }()

    // MARK: - Init

    init(user: Contact, config: Config, settingsStore: UserDefaultsStore, versions: Versions = .init()) {
        self.user = user
        self.config = config
        self.store = settingsStore
        self.versions = versions
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    // MARK: - View loading

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Theme.Color.commonWhiteColor

        setupSubviews()

        onReady?()
    }

    private func setupSubviews() {
        insertTableView()
    }

    private func insertTableView(){
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }

    private func makeHeader() -> UIView {
        let headerView = UIView()
        headerView.addSubview(iconImage)
        iconImage.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        iconImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return headerView
    }

    // MARK: - View Disappearing

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: - Long press handler

    @objc(longPress)
    private func longPress() {
        delegate?.settingsViewControllerDidUpdateUser(contact: user)
    }

    // MARK: - Reset

    private func reset() {
        store.resetConfigAndUser()
        delegate?.settingsViewControllerDidReset()
    }

    // MARK: - Present theme view controller

    func presentThemeViewController() {
#if SAMPLE_CUSTOMIZABLE_THEME
        delegate?.settingsViewControllerDidOpenTheme()
#endif
    }
}

#if SAMPLE_CUSTOMIZABLE_THEME
extension SettingsViewController: Themable {

    func themeChanged(theme: AppTheme) {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        view.subviews.forEach { subview in
            subview.tintColor = theme.accentColor.toUIColor()
        }
        (tableDatasource as? SettingsTableDataSource)?.themeChanged(theme: theme)
    }
}
#endif

private class SettingsTableDataSource: NSObject, UITableViewDataSource {

    private let cellIdentifier = "settingsTableViewCell"
    private let dataset: SettingsDataset

#if SAMPLE_CUSTOMIZABLE_THEME
    private var currentTheme: AppTheme?
#endif

    private var cells: [SettingsCell] = []

    init(dataset: SettingsDataset) {
        self.dataset = dataset
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        dataset.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section >= 0 && section < dataset.numberOfSections() else { return 0 }

        return dataset.section(at: section).numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section >= 0 && indexPath.section < dataset.numberOfSections() else { fatalError("Section not found") }

        let item = dataset.section(at: indexPath.section).item(at: indexPath.row)
        let cell = dequeueReusableCell(tableView)
        configureCell(cell, for: item)

        if !cells.contains(cell) {
            cells.append(cell)
        }

        return cell
    }

    private func dequeueReusableCell(_ tableView: UITableView) -> SettingsCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SettingsCell {
            return cell
        } else {
            return SettingsCell(reuseIdentifier: cellIdentifier)
        }
    }

    private func configureCell(_ cell: SettingsCell, for item: SettingsItem) {
        cell.textLabel?.text = item.title
        cell.textLabel?.textAlignment = item.textAlignment
        cell.detailTextLabel?.text = item.description

        cell.cellStyle = item.style

#if SAMPLE_CUSTOMIZABLE_THEME
        if let currentTheme = currentTheme {
            cell.themeChanged(theme: currentTheme)
        }
#endif
    }
}

#if SAMPLE_CUSTOMIZABLE_THEME
extension SettingsTableDataSource: Themable {

    func themeChanged(theme: AppTheme) {
        currentTheme = theme

        cells.forEach { cell in
            cell.themeChanged(theme: theme)
        }
    }
}
#endif

private class SettingsTableDelegate: NSObject, UITableViewDelegate {

    private let dataset: SettingsDataset
    private let headerBuilder: () -> UIView?

    init(dataset: SettingsDataset, detailsHeaderBuilder: @escaping () -> UIView?) {
        self.dataset = dataset
        self.headerBuilder = detailsHeaderBuilder
        super.init()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 250 : 30
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section < dataset.numberOfSections() else { return false }

        let item = dataset.item(for: indexPath)
        return item?.action != nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section == 0 ? headerBuilder() : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < dataset.numberOfSections() else { return }

        let item = dataset.item(for: indexPath)
        item?.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private struct SettingsItem {

    let title: String
    let description: String?
    let textAlignment: NSTextAlignment
    let style: SettingsCell.CellStyle
    let action: (() -> Void)?

    init(title: String, description: String? = nil, alignment: NSTextAlignment = .left, style: SettingsCell.CellStyle = .normal, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.textAlignment = alignment
        self.action = action
        self.style = style
    }
}

private struct SettingsDataset {

    private let sections: [Section<SettingsItem>]

    init(sections: [Section<SettingsItem>]) {
        self.sections = sections
    }

    func numberOfSections() -> Int {
        sections.count
    }

    func section(at index: Int) -> Section<SettingsItem> {
        sections[index]
    }

    func item(for indexPath: IndexPath) -> SettingsItem? {
        guard indexPath.section < numberOfSections() else { return nil }

        let section = sections[indexPath.section]
        guard indexPath.row < section.numberOfItems() else { return nil }
        return section.item(at: indexPath.row)
    }

}

private struct Section<Item> {

    private let items: [Item]

    init(items: [Item]) {
        self.items = items
    }

    func numberOfItems() -> Int {
        items.count
    }

    func item(at index: Int) -> Item {
        items[index]
    }

}

private class SettingsDatasetBuilder {

    private var sections = [SectionBuilder]()

    @discardableResult
    func addSection(_ section: (SectionBuilder) -> Void) -> Self {
        let builder = SectionBuilder()
        section(builder)
        sections.append(builder)
        return self
    }

    func build() -> SettingsDataset {
        SettingsDataset(sections: sections.compactMap({ $0.build() }))
    }
}

private class SectionBuilder {

    private var items = [SettingsItem]()

    @discardableResult
    func addUsernameItem(_ user: String) -> Self {
        items.append(.init(title: Strings.Settings.username, description: user))
        return self
    }

    @discardableResult
    func addEnvironmentItem(_ environment: Config.Environment) -> Self {
        items.append(.init(title: Strings.Settings.environment, description: environment.rawValue))
        return self
    }

    @discardableResult
    func addRegionItem(_ region: Config.Region) -> Self {
        items.append(.init(title: Strings.Settings.region, description: region.rawValue))
        return self
    }

    @discardableResult
    func addAppVersionItem(_ version: String) -> Self {
        items.append(.init(title: Strings.Settings.appVersion, description: version))
        return self
    }

    @discardableResult
    func addSDKVersionItem(_ version: String) -> Self {
        items.append(.init(title: Strings.Settings.sdkVersion, description: version))
        return self
    }

    @discardableResult
    func addLogoutItem(action: @escaping () -> Void) -> Self {
        items.append(.init(title: Strings.Settings.logout, description: nil, alignment: .center, style: .normal, action: action))
        return self
    }

    @discardableResult
    func addResetItem(action: @escaping () -> Void) -> Self {
        items.append(.init(title: Strings.Settings.reset, description: nil, alignment: .center, style: .danger, action: action))
        return self
    }

    @discardableResult
    func addThemeItem(action: @escaping () -> Void) -> Self {
#if SAMPLE_CUSTOMIZABLE_THEME
        items.append(.init(title: Strings.Settings.changeTheme, action: action))
#endif
        return self
    }

    @discardableResult
    func addShareLogs(action: (() -> Void)?) -> Self {
        guard let action = action else { return self }
        items.append(.init(title: Strings.Debug.Logs.shareLogFiles, description: "🪲", action: action))
        return self
    }

    func build() -> Section<SettingsItem> {
        Section(items: items)
    }
}

private extension Version {

    func formattedValue() -> String {
        guard let build = self.build else { return marketing }

        return "\(marketing) - \(build)"
    }
}