// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import KaleyraVideoSDK

final class CallOptionsTableViewController: UITableViewController {

    private let appSettings: AppSettings
    private var options: CallOptions
    private let store: UserDefaultsStore
    private let services: ServicesFactory
    private var dataset = DataSet()
    private var tableViewFont: UIFont = UIFont.systemFont(ofSize: 20)
    private var tableViewAccessoryFont: UIFont = UIFont.systemFont(ofSize: 18)

    var onDismiss: ((CallOptions) -> Void)?

    init(appSettings: AppSettings, services: ServicesFactory) {
        self.appSettings = appSettings
        self.options = appSettings.callSettings
        self.store = services.makeUserDefaultsStore()
        self.services = services
        super.init(style: .insetGrouped)
#if SAMPLE_CUSTOMIZABLE_THEME
        themeChanged(theme: services.makeThemeStorage().getSelectedTheme())
#endif
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    // MARK: - View loading

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.CallSettings.title
        setupTableViewContentInset()
        registerReusableCells()
        insertTableViewFooter()
    }

    private func setupTableViewContentInset() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    private func registerReusableCells() {
        tableView.registerReusableCell(UITableViewCell.self)
        tableView.registerReusableCell(SwitchTableViewCell.self)
        tableView.registerReusableCell(TextFieldTableViewCell.self)
    }

    private func insertTableViewFooter() {
        let footer = ButtonTableFooter(frame: .init(x: 0, y: 0, width: 150, height: 50))
        footer.buttonTitle = Strings.CallSettings.confirm
        footer.buttonAction = { [weak self] in
            guard let self else { return }

            self.dismiss(animated: true, completion: nil)
        }
        tableView.tableFooterView = footer
    }

    // MARK: - View will disappear

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        store.storeCallOptions(options)
        appSettings.callSettings = options
        onDismiss?(options)
    }

    // MARK: - Table data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataset.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataset.sectionTitle(section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataset.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = dataset.section(at: indexPath.section)

        switch section {
            case .callType:
                let cell = tableView.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = dataset.rowTitle(at: indexPath)
                cell.selectionStyle = .none
                cell.textLabel?.font = tableViewFont
                cell.detailTextLabel?.font = tableViewAccessoryFont
                cell.tintColor = Theme.Color.secondary
                cell.accessoryView = nil
                cell.accessoryType = KaleyraVideoSDK.CallOptions.CallType(row: indexPath.row) == options.type ? .checkmark : .none
                return cell
            case .recording:
                let cell = tableView.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = dataset.rowTitle(at: indexPath)
                cell.selectionStyle = .none
                cell.textLabel?.font = tableViewFont
                cell.detailTextLabel?.font = tableViewAccessoryFont
                cell.tintColor = Theme.Color.secondary
                cell.accessoryView = nil
                cell.accessoryType = KaleyraVideoSDK.CallOptions.RecordingType(row: indexPath.row) == options.recording ? .checkmark : .none
                return cell
            case .callOptions:
                let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.text = String(options.maximumDuration)
                cell.onTextChanged = { [weak self] text in
                    if let text = text, let value = UInt(text) {
                        self?.options.maximumDuration = value
                    } else {
                        self?.options.maximumDuration = 0
                    }
                }
                return cell
            case .group:
                let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.isOn = options.isGroup
                cell.textLabel?.text = dataset.rowTitle(indexPath.section, row: indexPath.row)
                cell.textLabel?.font = tableViewFont
                cell.onSwitchValueChange = { [weak self] cell in
                    self?.options.isGroup = cell.isOn
                }
                return cell
            case .rating:
                let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.isOn = options.showsRating
                cell.textLabel?.text = dataset.rowTitle(indexPath.section, row: indexPath.row)
                cell.textLabel?.font = tableViewFont
                cell.onSwitchValueChange = { [weak self] cell in
                    self?.options.showsRating = cell.isOn
                }
                return cell
            case .callPresentationMode:
                let cell = tableView.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = dataset.rowTitle(indexPath.section, row: indexPath.row)
                cell.selectionStyle = .none
                cell.textLabel?.font = tableViewFont
                cell.detailTextLabel?.font = tableViewAccessoryFont
                cell.tintColor = Theme.Color.secondary
                cell.accessoryView = nil
                cell.accessoryType = indexPath.row == options.presentationMode.rawValue ? .checkmark : .none
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataset.section(at: indexPath) {
            case .callType:
                onCallTypeCellSelected(tableView, at: indexPath)
            case .recording:
                onRecordingTypeCellSelected(tableView, at: indexPath)
            case .callPresentationMode:
                onCallPresentationModeCellSelected(tableView, at: indexPath)
            default:
                return
        }
    }

    private func onCallTypeCellSelected(_ tableView: UITableView, at indexPath: IndexPath) {
        guard let type = KaleyraVideoSDK.CallOptions.CallType(row: indexPath.row) else { return }

        options.type = type
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    private func onRecordingTypeCellSelected(_ tableView: UITableView, at indexPath: IndexPath) {
        options.recording = .init(row: indexPath.row)
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    private func onCallPresentationModeCellSelected(_ tableView: UITableView, at indexPath: IndexPath) {
        guard let mode = CallOptions.PresentationMode(rawValue: indexPath.row) else { return }

        options.presentationMode = mode
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    // MARK: - Data set

    private enum SectionType {
        case callType
        case recording
        case callOptions
        case group
        case rating
        case callPresentationMode

        var title: String {
            switch self {
                case .callType:
                    return Strings.CallSettings.CallTypeSection.title
                case .recording:
                    return Strings.CallSettings.RecordingSection.title
                case .callOptions:
                    return Strings.CallSettings.CallOptionsSection.title
                case .group:
                    return Strings.CallSettings.GroupSection.title
                case .rating:
                    return Strings.CallSettings.RatingSection.title
                case .callPresentationMode:
                    return Strings.CallSettings.CallPresentationMode.title
            }
        }
    }

    private struct DataSet {

        private var sections = [Section]()

        private struct Section  {
            let type: SectionType
            let rows: [Row]
        }

        private struct Row {
            let title: String
        }

        init() {
            sections.append(Section(type: .callType,
                                    rows: [.init(title: Strings.CallSettings.CallTypeSection.audioVideo),
                                           .init(title: Strings.CallSettings.CallTypeSection.audioUpgradable),
                                           .init(title: Strings.CallSettings.CallTypeSection.audioOnly)]))
            sections.append(Section(type: .recording,
                                    rows: [.init(title: Strings.CallSettings.RecordingSection.none),
                                           .init(title: Strings.CallSettings.RecordingSection.automatic),
                                           .init(title: Strings.CallSettings.RecordingSection.manual)]))
            sections.append(Section(type: .callOptions,
                                    rows: [.init(title: Strings.CallSettings.CallOptionsSection.duration)]))
            sections.append(Section(type: .group,
                                    rows: [.init(title: Strings.CallSettings.GroupSection.conference)]))
            sections.append(Section(type: .rating,
                                    rows: [.init(title: Strings.CallSettings.RatingSection.enabled)]))
            sections.append(Section(type: .callPresentationMode,
                                    rows: [.init(title: Strings.CallSettings.CallPresentationMode.fullscreen),
                                           .init(title: Strings.CallSettings.CallPresentationMode.pip)]))
        }

        func numberOfSections() -> Int {
            sections.count
        }

        func section(at index: Int) -> SectionType {
            sections[index].type
        }

        func section(at indexPath: IndexPath) -> SectionType {
            section(at: indexPath.section)
        }

        func sectionTitle(_ section: Int) -> String? {
            sections[section].type.title
        }

        func numberOfRowsInSection(_ section: Int) -> Int {
            sections[section].rows.count
        }

        func rowTitle(at indexPath: IndexPath) -> String? {
            rowTitle(indexPath.section, row: indexPath.row)
        }

        func rowTitle(_ section: Int, row: Int) -> String? {
            sections[section].rows[row].title
        }
    }
}

private extension KaleyraVideoSDK.CallOptions.CallType {

    init?(row: Int) {
        switch row {
            case 0:
                self = .audioVideo
            case 1:
                self = .audioUpgradable
            case 2:
                self = .audioOnly
            default:
                return nil
        }
    }
}

private extension KaleyraVideoSDK.CallOptions.RecordingType {

    init?(row: Int) {
        switch row {
            case 1:
                self = .automatic
            case 2:
                self = .manual
            default:
                return nil
        }
    }
}

#if SAMPLE_CUSTOMIZABLE_THEME

extension CallOptionsTableViewController: Themable {
    func themeChanged(theme: AppTheme) {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        tableViewFont = theme.font?.toUIFont() ?? UIFont.systemFont(ofSize: 20)
        tableViewAccessoryFont = theme.secondaryFont?.toUIFont() ?? UIFont.systemFont(ofSize: 18)
        view.subviews.forEach { subview in
            subview.tintColor = theme.accentColor.toUIColor()
        }

        tableView.reloadData()
    }
}

#endif
