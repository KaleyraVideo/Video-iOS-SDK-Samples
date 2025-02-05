// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import KaleyraVideoSDK

final class CallSettingsViewController: UITableViewController {

    private let appSettings: AppSettings
    private lazy var dataSource: SectionedTableDataSource = {
        .create(for: appSettings, onEditButtons: onEditButtons)
    }()

    var onDismiss: (() -> Void)?
    var onEditButtons: (() -> Void)?

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    // MARK: - View loading

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.CallSettings.title
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        dataSource.registerReusableCells(tableView)
        tableView.tableFooterView = ButtonTableFooter(title: Strings.CallSettings.confirm) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - View will disappear

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        onDismiss?()
    }
}

private extension SectionedTableDataSource {

    static func create(for settings: AppSettings, onEditButtons: (() -> Void)?) -> SectionedTableDataSource {
        .init(sections: [
            SingleChoiceTableViewSection(header: Strings.CallSettings.CallTypeSection.title,
                                         options: [CallOptions.CallType.audioVideo, CallOptions.CallType.audioUpgradable, CallOptions.CallType.audioOnly],
                                         selected: settings.callSettings.type,
                                         optionName: CallTypePresenter.optionName,
                                         onChange: { settings.callSettings.type = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.RecordingSection.title,
                                         options: [CallOptions.RecordingType?.none, CallOptions.RecordingType.automatic, CallOptions.RecordingType.manual],
                                         selected: settings.callSettings.recording,
                                         optionName: RecordingPresenter.optionName(_:),
                                         onChange: { settings.callSettings.recording = $0 }),
            TextFieldSection(header: Strings.CallSettings.DurationSection.title, value: "\(settings.callSettings.maximumDuration)", onChange: { settings.callSettings.maximumDuration = UInt($0) ?? 0 }),
            ToggleSection(header: Strings.CallSettings.GroupSection.title, description: Strings.CallSettings.GroupSection.conference, value: settings.callSettings.isGroup, onChange: { settings.callSettings.isGroup = $0 }),
            ToolsSection(config: settings.callSettings.tools, onChange: { settings.callSettings.tools = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.CameraSection.title,
                                         options: [CallSettings.CameraPosition.front, CallSettings.CameraPosition.back],
                                         selected: settings.callSettings.cameraPosition,
                                         optionName: CameraPositionPresenter.optionName,
                                         onChange: { settings.callSettings.cameraPosition = $0 }),
            ConfigurableSection(rows: [
                ToggleRow(title: "Enable custom buttons", value: settings, keypath: \.callSettings.enableCustomButtons, onChange: nil),
                DisclosureRow(title: "Customize buttons", onSelect: onEditButtons)
            ], header: "Custom buttons"),
            ToggleSection(header: Strings.CallSettings.RatingSection.title, description: Strings.CallSettings.RatingSection.enabled, value: settings.callSettings.showsRating, onChange: { settings.callSettings.showsRating = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.PresentationMode.title, options: [CallSettings.PresentationMode.fullscreen, CallSettings.PresentationMode.pip], selected: settings.callSettings.presentationMode, optionName: PresentationModePresenter.optionName, onChange: { settings.callSettings.presentationMode = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.SpeakerSection.title, options: [KaleyraVideoSDK.ConferenceSettings.SpeakerOverride.always, KaleyraVideoSDK.ConferenceSettings.SpeakerOverride.video, KaleyraVideoSDK.ConferenceSettings.SpeakerOverride.videoForeground, KaleyraVideoSDK.ConferenceSettings.SpeakerOverride.never], selected: settings.callSettings.speakerOverride, optionName: SpeakerOverridePresenter.optionName, onChange: { settings.callSettings.speakerOverride = $0 })
        ])
    }

    private enum CallTypePresenter {

        static func optionName(_ type: CallOptions.CallType) -> String {
            switch type {
                case .audioVideo:
                    Strings.CallSettings.CallTypeSection.audioVideo
                case .audioUpgradable:
                    Strings.CallSettings.CallTypeSection.audioUpgradable
                case .audioOnly:
                    Strings.CallSettings.CallTypeSection.audioOnly
            }
        }
    }

    private enum RecordingPresenter {

        static func optionName(_ type: CallOptions.RecordingType?) -> String {
            switch type {
                case nil:
                    Strings.CallSettings.RecordingSection.none
                case .automatic:
                    Strings.CallSettings.RecordingSection.automatic
                case .manual:
                    Strings.CallSettings.RecordingSection.manual
            }
        }
    }

    private enum PresentationModePresenter {

        static func optionName(_ mode: CallSettings.PresentationMode) -> String {
            switch mode {
                case .fullscreen:
                    Strings.CallSettings.PresentationMode.fullscreen
                case .pip:
                    Strings.CallSettings.PresentationMode.pip
            }
        }
    }

    private enum CameraPositionPresenter {

        static func optionName(_ position: CallSettings.CameraPosition) -> String {
            switch position {
                case .front:
                    Strings.CallSettings.CameraSection.front
                case .back:
                    Strings.CallSettings.CameraSection.back
            }
        }
    }

    private enum SpeakerOverridePresenter {

        static func optionName(_ mode: ConferenceSettings.SpeakerOverride) -> String {
            switch mode {
                case .never:
                    Strings.CallSettings.SpeakerSection.never
                case .always:
                    Strings.CallSettings.SpeakerSection.always
                case .video:
                    Strings.CallSettings.SpeakerSection.video
                case .videoForeground:
                    Strings.CallSettings.SpeakerSection.videoInForeground
            }
        }
    }
}
