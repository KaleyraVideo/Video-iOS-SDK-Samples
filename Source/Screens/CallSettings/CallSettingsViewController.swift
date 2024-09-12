// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import KaleyraVideoSDK

final class CallSettingsViewController: UITableViewController {

    fileprivate final class ViewModel {

        var settings: CallSettings

        init(settings: CallSettings) {
            self.settings = settings
        }
    }

    private let appSettings: AppSettings
    private let model: ViewModel
    private let store: UserDefaultsStore
    private let services: ServicesFactory
    private lazy var dataSource: SectionedTableDataSource = .create(for: model)

    var onDismiss: (() -> Void)?

    init(appSettings: AppSettings, services: ServicesFactory) {
        self.appSettings = appSettings
        self.model = .init(settings: appSettings.callSettings)
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
        setupTableView()
    }

    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        dataSource.registerReusableCells(tableView)
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

        store.storeCallOptions(model.settings)
        appSettings.callSettings = model.settings
        onDismiss?()
    }
}

private extension SectionedTableDataSource {

    static func create(for model: CallSettingsViewController.ViewModel) -> SectionedTableDataSource {
        .init(sections: [
            SingleChoiceTableViewSection(header: Strings.CallSettings.CallTypeSection.title,
                                         options: [CallOptions.CallType.audioVideo, CallOptions.CallType.audioUpgradable, CallOptions.CallType.audioOnly],
                                         selected: model.settings.type,
                                         optionName: CallTypePresenter.optionName,
                                         onChange: { model.settings.type = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.RecordingSection.title,
                                         options: [CallOptions.RecordingType?.none, CallOptions.RecordingType.automatic, CallOptions.RecordingType.manual],
                                         selected: model.settings.recording,
                                         optionName: RecordingPresenter.optionName(_:),
                                         onChange: { model.settings.recording = $0 }),
            TextFieldSection(header: Strings.CallSettings.DurationSection.title, value: "\(model.settings.maximumDuration)", onChange: { model.settings.maximumDuration = UInt($0) ?? 0 }),
            ToggleSection(header: Strings.CallSettings.GroupSection.title, description: Strings.CallSettings.GroupSection.conference, value: model.settings.isGroup, onChange: { model.settings.isGroup = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.CameraSection.title,
                                         options: [CallSettings.CameraPosition.front, CallSettings.CameraPosition.back],
                                         selected: model.settings.cameraPosition,
                                         optionName: CameraPositionPresenter.optionName(_:),
                                         onChange: { model.settings.cameraPosition = $0 }),
            ToggleSection(header: Strings.CallSettings.RatingSection.title, description: Strings.CallSettings.RatingSection.enabled, value: model.settings.showsRating, onChange: { model.settings.showsRating = $0 }),
            SingleChoiceTableViewSection(header: Strings.CallSettings.PresentationMode.title, options: [CallSettings.PresentationMode.fullscreen, CallSettings.PresentationMode.pip], selected: model.settings.presentationMode, optionName: PresentationModePresenter.optionName(_:), onChange: { model.settings.presentationMode = $0 })

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
}

#if SAMPLE_CUSTOMIZABLE_THEME

extension CallSettingsViewController: Themable {
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
