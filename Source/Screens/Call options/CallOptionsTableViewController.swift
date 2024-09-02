// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import KaleyraVideoSDK

final class CallOptionsTableViewController: UITableViewController {

    private var options: CallOptions
    private let services: ServicesFactory
    private var dataset = DataSet()
    private var tableViewFont: UIFont = UIFont.systemFont(ofSize: 20)
    private var tableViewAccessoryFont: UIFont = UIFont.systemFont(ofSize: 18)

    var onDismiss: ((CallOptions) -> Void)?

    init(options: CallOptions, services: ServicesFactory) {
        self.options = options
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
            guard let self = self else { return }

            self.dismiss(animated: true, completion: nil)
        }
        tableView.tableFooterView = footer
    }

    override func viewWillDisappear(_ animated: Bool) {
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
                cell.textLabel?.text = dataset.rowTitle(indexPath.section, row: indexPath.row)
                cell.selectionStyle = .none
                cell.textLabel?.font = tableViewFont
                cell.detailTextLabel?.font = tableViewAccessoryFont
                cell.tintColor = Theme.Color.secondary
                cell.accessoryView = nil
                cell.accessoryType = callTypeFor(row: indexPath.row) == options.type ? .checkmark : .none
                return cell
            case .recording:
                let cell = tableView.dequeueReusableCell(for: indexPath)
                cell.textLabel?.text = dataset.rowTitle(indexPath.section, row: indexPath.row)
                cell.selectionStyle = .none
                cell.textLabel?.font = tableViewFont
                cell.detailTextLabel?.font = tableViewAccessoryFont
                cell.tintColor = Theme.Color.secondary
                cell.accessoryView = nil
                cell.accessoryType = recordingTypeFor(row: indexPath.row) == options.recording ? .checkmark : .none
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
                cell.selectionStyle = .none
                cell.textLabel?.font = tableViewFont
                cell.onSwitchValueChange = { [weak self] cell in
                    self?.options.isGroup = cell.isOn
                }
                return cell
            case .rating:
                let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.isOn = options.showsRating
                cell.textLabel?.text = dataset.rowTitle(indexPath.section, row: indexPath.row)
                cell.selectionStyle = .none
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
        if indexPath.section == 0 {
            onCallTypeCellSelected(tableView, at: indexPath)
        } else if indexPath.section == 1 {
            onRecordingTypeCellSelected(tableView, at: indexPath)
        } else if indexPath.section == 5 {
            onCallPresentationModeCellSelected(tableView, at: indexPath)
        }
    }

    private func onCallTypeCellSelected(_ tableView: UITableView, at indexPath: IndexPath) {
        guard let type = callTypeFor(row: indexPath.row) else { return }

        options.type = type
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    private func onRecordingTypeCellSelected(_ tableView: UITableView, at indexPath: IndexPath) {
        guard let type = recordingTypeFor(row: indexPath.row) else { return }

        options.recording = type
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    private func onCallPresentationModeCellSelected(_ tableView: UITableView, at indexPath: IndexPath) {
        guard let mode = CallOptions.PresentationMode(rawValue: indexPath.row) else { return }

        options.presentationMode = mode
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    private func callTypeFor(row: Int) -> KaleyraVideoSDK.CallOptions.CallType? {
        switch row {
            case 0:
                .audioVideo
            case 1:
                .audioUpgradable
            case 2:
                .audioOnly
            default:
                nil
        }
    }

    private func recordingTypeFor(row: Int) -> KaleyraVideoSDK.CallOptions.RecordingType? {
        switch row {
            case 0:
                nil
            case 1:
                .automatic
            case 2:
                .manual
            default:
                nil
        }
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

        func sectionTitle(_ section: Int) -> String? {
            sections[section].type.title
        }

        func numberOfRowsInSection(_ section: Int) -> Int {
            sections[section].rows.count
        }

        func rowTitle(_ section: Int, row: Int) -> String? {
            sections[section].rows[row].title
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
