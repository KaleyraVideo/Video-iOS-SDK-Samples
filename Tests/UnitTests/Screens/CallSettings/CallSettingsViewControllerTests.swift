// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class CallSettingsViewControllerTests: UnitTestCase, CompletionSpyFactory {

    private var appSettings: AppSettings!
    private var store: UserDefaultsStore!
    private var userDefaults: UserDefaults!
    private var sut: CallSettingsViewController!

    override func setUp() {
        super.setUp()

        userDefaults = .testSuite
        store = .init(userDefaults: userDefaults)
        appSettings = .init(repository: store)
        sut = .init(appSettings: appSettings)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: .testSuite)
        userDefaults.synchronize()
        store = nil
        appSettings = nil
        sut = nil

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.CallSettings.title))
    }

    func testLoadViewShouldSetupTableView() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView.style, equalTo(.insetGrouped))
    }

    func testLoadViewShouldReloadData() {
        sut.loadViewIfNeeded()

        assertThat(sut.numberOfSections(), equalTo(10))
        assertThat(sut.numberOfRowsIn(section: .callType), equalTo(3))
        assertThat(sut.numberOfRowsIn(section: .recording), equalTo(3))
        assertThat(sut.numberOfRowsIn(section: .duration), equalTo(1))
        assertThat(sut.numberOfRowsIn(section: .tools), equalTo(5))
        assertThat(sut.numberOfRowsIn(section: .group), equalTo(1))
        assertThat(sut.numberOfRowsIn(section: .camera), equalTo(2))
        assertThat(sut.numberOfRowsIn(section: .rating), equalTo(1))
        assertThat(sut.numberOfRowsIn(section: .presentationMode), equalTo(2))
    }

    func testSetupDurationCell() throws {
        sut.loadViewIfNeeded()

        let cell = sut.callDurationCell()

        assertThat(cell, present())
        assertThat(cell?.selectionStyle, presentAnd(equalTo(.none)))
        assertThat(cell?.tintColor.cgColor, presentAnd(equalTo(Theme.Color.secondary.cgColor)))
        assertThat(cell?.textField?.textAlignment, equalTo(.natural))
        assertThat(cell?.textField?.inputAccessoryView, present())

        let durationTextField = try unwrap(cell?.textField)
        let toolBar: UIToolbar = try unwrap(durationTextField.inputAccessoryView as? UIToolbar)
        let doneButtonItem = try unwrap(toolBar.items?.last)
        assertThat(doneButtonItem.style, equalTo(.plain))
        assertThat(doneButtonItem.title, equalTo(Strings.CallSettings.confirm))
    }

    func testSetupRecordingTypeCell() {
        sut.loadViewIfNeeded()

        let cell = sut.recordingCell()

        assertThat(cell?.selectionStyle, presentAnd(equalTo(.none)))
        assertThat(cell?.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
    }

    func testSetupGroupCallCell() throws {
        sut.loadViewIfNeeded()

        let cell = sut.groupCell()

        assertThat(cell, present())
        assertThat(cell?.switch?.onTintColor?.resolvedLight, equalTo(Theme.Color.secondary.resolvedLight))
        assertThat(cell?.switch?.allTargets, presentAnd(hasCount(1)))
    }

    func testSetupRatingCell() throws {
        sut.loadViewIfNeeded()

        let cell = sut.ratingCell()

        assertThat(cell, present())
        assertThat(cell?.switch?.onTintColor?.resolvedDark, equalTo(Theme.Color.secondary.resolvedDark))
        assertThat(cell?.switch?.allTargets, presentAnd(hasCount(1)))
    }

    func testSetupCameraCell() throws {
        sut.loadViewIfNeeded()

        let cell = sut.cameraCell()

        assertThat(cell, present())
        assertThat(cell?.textLabel?.text, presentAnd(equalTo(Strings.CallSettings.CameraSection.front)))
    }

    func testSetupSpeakerOverride() throws {
        sut.loadViewIfNeeded()

        let cell = sut.speakerOverride()

        assertThat(cell, present())
        assertThat(cell?.textLabel?.text, presentAnd(equalTo(Strings.CallSettings.SpeakerSection.always)))
    }

    func testWhenViewDisappearsShouldNotifyDismissCallback() throws {
        let callback = makeVoidCompletionSpy()
        sut.onDismiss = callback.callAsFunction
        sut.loadViewIfNeeded()

        sut.simulateRowSelectedAt(1, inSection: .callType)

        let durationCell = sut.callDurationCell()
        durationCell?.simulateTextChanged("100")

        let groupCallCell = sut.groupCell()
        groupCallCell?.switch?.isOn = true
        groupCallCell?.switch?.simulate(event: .valueChanged)

        let ratingCell = sut.ratingCell()
        ratingCell?.switch?.isOn = true
        ratingCell?.switch?.simulate(event: .valueChanged)

        sut.viewWillDisappear(false)

        assertThat(callback.invocations, hasCount(1))
    }

    func testWhenViewDisappearsShouldStoreSettingsInStore() throws {
        sut.loadViewIfNeeded()

        sut.simulateRowSelectedAt(1, inSection: .callType)
        sut.viewWillDisappear(false)

        let stored = try store.loadSettings()
        assertThat(stored.type, equalTo(.audioUpgradable))
    }

    func testWhenViewDisappearsShouldUpdateAppSettings() {
        sut.loadViewIfNeeded()

        sut.simulateRowSelectedAt(1, inSection: .callType)
        sut.viewWillDisappear(false)

        var expected = CallSettings()
        expected.type = .audioUpgradable
        assertThat(appSettings.callSettings, equalTo(expected))
    }
}

private extension CallSettingsViewController {

    enum Section: Int {
        case callType
        case recording
        case duration
        case group
        case tools
        case camera
        case buttons
        case rating
        case presentationMode
        case speakerOverride
    }

    func numberOfSections() -> Int {
        tableView.numberOfSections
    }

    func numberOfRowsIn(section: Section) -> Int {
        tableView.numberOfRows(inSection: section.rawValue)
    }

    func recordingCell() -> UITableViewCell? {
        cellForRow(at: 0, section: .recording)
    }

    func callDurationCell() -> TextFieldTableViewCell? {
        cellForRow(at: 0, section: .duration) as? TextFieldTableViewCell
    }

    func groupCell() -> SwitchTableViewCell? {
        cellForRow(at: 0, section: .group) as? SwitchTableViewCell
    }

    func cameraCell() -> UITableViewCell? {
        cellForRow(at: 0, section: .camera)
    }

    func ratingCell() -> SwitchTableViewCell? {
        cellForRow(at: 0, section: .rating) as? SwitchTableViewCell
    }

    func speakerOverride() -> UITableViewCell? {
        cellForRow(at: 0, section: .speakerOverride)
    }

    private func cellForRow(at rowIndex: Int, section: Section) -> UITableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: rowIndex, section: section.rawValue))
    }

    func simulateRowSelectedAt(_ rowIndex: Int, inSection section: Section) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: rowIndex, section: section.rawValue))
    }
}
