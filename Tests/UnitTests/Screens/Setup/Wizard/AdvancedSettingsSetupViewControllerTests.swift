// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class AdvancedSettingsSetupViewControllerTests: UnitTestCase {

    func testSetupsSectionsAndSectionRows() {
        let sut = makeSUT()

        assertThat(sut.numberOfSections(), equalTo(3))
        assertThat(sut.numberOfRowsInToolsSection(), equalTo(5))
        assertThat(sut.numberOfRowsInVoIPSection(), equalTo(4))
        assertThat(sut.numberOfRowsInUserDetailsSection(), equalTo(1))
    }

    // MARK: - User details

    func testSetupForShowUserInfoSection() throws {
        let sut = makeSUT(voipConfig: .default, showUserInfo: true)

        let cell = try unwrap(sut.userInfoCell())

        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))

        let multipleUserSwitch = try unwrap(cell.accessoryView as? UISwitch)

        assertThat(multipleUserSwitch.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(multipleUserSwitch.allTargets.count, equalTo(1))
    }

    // MARK: - VoIP

    func testVoIPSectionHeader() {
        let sut = makeSUT()

        let section = sut.voipSectionHeader()

        assertThat(section, presentAnd(equalTo(Strings.Setup.VoIPSection.title)))
    }

//    func testFirstCellForVoIPSectionShouldPresentVoIPManualManagementConfiguration() throws {
//        let config = Config.VoIP.manual(strategy: .backgroundOnly)
//        let sut = makeSUT(voipConfig: config)
//        sut.loadViewIfNeeded()
//
//        let cell = try unwrap(sut.manualVoIPCell())
//
//        assertThat(cell.selectionStyle, equalTo(.none))
//        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
//        assertThat(cell.textLabel?.text, presentAnd(equalToLocalizedString("setup.voip_manual_management", bundle: .main)))
//        assertThat(cell.onSwitchValueChange, present())
//        assertThat(cell.`switch`?.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
//        assertThat(cell.`switch`?.allTargets.count, equalTo(1))
//        assertThat(cell.`switch`?.isOn, presentAnd(isTrue()))
//    }
//
//    func testSecondCellForVoIPSectionShouldPresentReceiveVoIPNotificationsInForegroundConfiguration() throws {
//        let config = Config.VoIP.automatic(strategy: .always)
//        let sut = makeSUT(voipConfig: config)
//        sut.loadViewIfNeeded()
//
//        let cell = try unwrap(sut.receiveNotificationsInForegroundCell())
//
//        assertThat(cell.selectionStyle, equalTo(.none))
//        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
//        assertThat(cell.textLabel?.text, presentAnd(equalToLocalizedString("setup.voip_notifications_in_foreground", bundle: .main)))
//        assertThat(cell.onSwitchValueChange, present())
//        assertThat(cell.`switch`?.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
//        assertThat(cell.`switch`?.allTargets.count, equalTo(1))
//        assertThat(cell.`switch`?.isOn, presentAnd(isTrue()))
//    }
//
//    func testThirdCellForVoIPSectionShouldPresentDisableDirectIncomingCallsConfiguration() throws {
//        let config = Config.VoIP.disabled
//        let sut = makeSUT(voipConfig: config)
//        sut.loadViewIfNeeded()
//
//        let cell = try unwrap(sut.disableDirectIncomingCallsCell())
//
//        assertThat(cell.selectionStyle, equalTo(.none))
//        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
//        assertThat(cell.textLabel?.text, presentAnd(equalToLocalizedString("setup.voip_disable_direct_incoming_calls", bundle: .main)))
//        assertThat(cell.onSwitchValueChange, present())
//        assertThat(cell.`switch`?.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
//        assertThat(cell.`switch`?.allTargets.count, equalTo(1))
//        assertThat(cell.`switch`?.isOn, presentAnd(isTrue()))
//    }

    // MARK: - Helpers

    private func makeSUT() -> AdvancedSettingsSetupViewController {
        makeSUT(voipConfig: .default, showUserInfo: true)
    }

    private func makeSUT(voipConfig: Config.VoIP, showUserInfo: Bool = true) -> AdvancedSettingsSetupViewController {
        .init(model: .init(toolsConfig: .init(), voipConfig: voipConfig, disableDirectIncomingCalls: false, showUserInfo: showUserInfo))
    }
}

private extension AdvancedSettingsSetupViewController {

    private enum Section: Int {
        case tools
        case voip
        case userDetails
    }

    // MARK: - Rows count

    func numberOfSections() -> Int {
        tableView.numberOfSections
    }

    func numberOfRowsInUserDetailsSection() -> Int {
        numberOfRowsInSection(.userDetails)
    }

    func numberOfRowsInToolsSection() -> Int {
        numberOfRowsInSection(.tools)
    }

    func numberOfRowsInVoIPSection() -> Int {
        numberOfRowsInSection(.voip)
    }

    private func numberOfRowsInSection(_ section: Section) -> Int {
        tableView.numberOfRows(inSection: section.rawValue)
    }

    // MARK: - Cells

    func userInfoCell() -> UITableViewCell? {
        cellFor(row: 0, section: .userDetails)
    }

    func voipCell() -> UITableViewCell? {
        cellFor(row: 0, section: .voip)
    }

    // MARK: - VoIP

    func manualVoIPCell() -> SwitchTableViewCell? {
        cellFor(row: 0, section: .voip) as? SwitchTableViewCell
    }

    func receiveNotificationsInForegroundCell() -> SwitchTableViewCell? {
        cellFor(row: 1, section: .voip) as? SwitchTableViewCell
    }

    func disableDirectIncomingCallsCell() -> SwitchTableViewCell? {
        cellFor(row: 2, section: .voip) as? SwitchTableViewCell
    }

    // MARK: - Headers

    func voipSectionHeader() -> String? {
        tableView(tableView, titleForHeaderInSection: Section.voip.rawValue)
    }

    private func cellFor(row: Int, section: Section) -> UITableViewCell? {
        cell(at: indexPath(row: row, section: section))
    }

    private func cell(at indexPath: IndexPath) -> UITableViewCell? {
        tableView(tableView, cellForRowAt: indexPath)
    }

    private func indexPath(row: Int, section: Section) -> IndexPath {
        IndexPath(row: row, section: section.rawValue)
    }
}
