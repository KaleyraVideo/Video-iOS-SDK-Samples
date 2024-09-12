// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestMatchers
@testable import SDK_Sample

final class AppSetupViewControllerTests: UnitTestCase {

    private var config = Config(keys: .any,
                                showUserInfo: true,
                                environment: .sandbox)

    func testTableViewStyleShouldBeInsetGroupedOnModernSystems() {
        let sut = makeSUT()

        assertThat(sut.tableView.style, equalTo(.insetGrouped))
    }

    func testTitle() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.Setup.title))
    }

    func testTableViewContentInsetHasABottomPadding() {
        let sut = makeSUT()

        assertThat(sut.tableView?.contentInset.top, equalTo(0))
        assertThat(sut.tableView?.contentInset.left, equalTo(0))
        assertThat(sut.tableView?.contentInset.right, equalTo(0))
        assertThat(sut.tableView?.contentInset.bottom, equalTo(20))
    }

    func testSetupsSectionsAndSectionRows() {
        let sut = makeSUT()

        assertThat(sut.numberOfSections(), equalTo(7))
        assertThat(sut.numberOfRowsInEnvironmentSection(), equalTo(3))
        assertThat(sut.numberOfRowsInRegionSection(), equalTo(4))
        assertThat(sut.numberOfRowsInAppIdSection(), equalTo(1))
        assertThat(sut.numberOfRowsInApiKeySection(), equalTo(1))
        assertThat(sut.numberOfRowsInUserDetailsSection(), equalTo(1))
        assertThat(sut.numberOfRowsInToolsSection(), equalTo(5))
        assertThat(sut.numberOfRowsInVoIPSection(), equalTo(4))
    }

    // MARK: - Environment

    func testEnvironmentSectionHeader() {
        let sut = makeSUT()

        let header = sut.environmentSectionHeader()

        assertThat(header, equalTo(Strings.Setup.EnvironmentSection.title))
    }

    func testShowsACellForEveryEnvironment() throws {
        let sut = makeSUT()

        let productionCell = try unwrap(sut.environmentCell(at: 0))
        let sandboxCell = try unwrap(sut.environmentCell(at: 1))
        let developCell = try unwrap(sut.environmentCell(at: 2))

        assertThat(productionCell.textLabel?.text, equalTo(Strings.Setup.EnvironmentSection.production))
        assertThat(sandboxCell.textLabel?.text, equalTo(Strings.Setup.EnvironmentSection.sandbox))
        assertThat(developCell.textLabel?.text, equalTo(Strings.Setup.EnvironmentSection.develop))
    }

    func testSetupShouldAddACheckmarkToTheCurrentlySelectedEnvironment() throws {
        let config = Config(keys: .any, showUserInfo: true, environment: .sandbox, region: .europe)
        let sut = makeSUT(config: config)

        let productionCell = try unwrap(sut.environmentCell(at: 0))
        let sandboxCell = try unwrap(sut.environmentCell(at: 1))
        let developCell = try unwrap(sut.environmentCell(at: 2))

        assertThat(productionCell.accessoryType, equalTo(.none))
        assertThat(sandboxCell.accessoryType, equalTo(.checkmark))
        assertThat(developCell.accessoryType, equalTo(.none))
    }

    // MARK: - Region

    func testRegionSectionHeader() {
        let sut = makeSUT()

        let header = sut.regionSectionHeader()

        assertThat(header, equalTo(Strings.Setup.RegionSection.title))
    }

    func testSetupShouldAddARowForEveryRegionInRegionSection() throws {
        let sut = makeSUT()

        let europeCell = try unwrap(sut.regionCell(at: 0))
        let indiaCell = try unwrap(sut.regionCell(at: 1))
        let usCell = try unwrap(sut.regionCell(at: 2))

        assertThat(europeCell.textLabel?.text, equalTo(Strings.Setup.RegionSection.europe))
        assertThat(indiaCell.textLabel?.text, equalTo(Strings.Setup.RegionSection.india))
        assertThat(usCell.textLabel?.text, equalTo(Strings.Setup.RegionSection.us))
    }

    func testSetupShouldAddACheckmarkToTheCurrentlySelectedRegion() throws {
        let config = Config(keys: .any, showUserInfo: true, region: .india)
        let sut = makeSUT(config: config)

        let europeCell = try unwrap(sut.regionCell(at: 0))
        let indiaCell = try unwrap(sut.regionCell(at: 1))

        assertThat(europeCell.accessoryType, equalTo(.none))
        assertThat(indiaCell.accessoryType, equalTo(.checkmark))
    }

    func testSelectRegionRowShouldUpdateSectionPuttingACheckmarkAlongSelectedRegion() throws {
        let config = Config(keys: .any, showUserInfo: false, region: .europe)
        let sut = makeSUT(config: config)

        sut.simulateIndiaRegionSelected()

        let europeCell = try unwrap(sut.regionCell(at: 0))
        let indiaCell = try unwrap(sut.regionCell(at: 1))
        let usCell = try unwrap(sut.regionCell(at: 2))

        assertThat(europeCell.accessoryType, equalTo(.none))
        assertThat(indiaCell.accessoryType, equalTo(.checkmark))
        assertThat(usCell.accessoryType, equalTo(.none))
    }

    // MARK: - App Id

    func testSetupAppIdCell() throws {
        let keys = Config.Keys.any
        let config = Config(keys: keys)
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.appIdCell())

        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(cell.text, presentAnd(equalTo(keys.appId.description)))
    }

    // MARK: - Api key

    func testSetupAppKeyCell() throws {
        let keys = Config.Keys.any
        let config = Config(keys: keys)
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.apiKeyCell())

        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(cell.text, presentAnd(equalTo(keys.apiKey.description)))
    }

    // MARK: - User details

    func testSetupForShowUserInfoSection() throws {
        let config = Config(keys: .any, showUserInfo: true)
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.userInfoCell())

        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(cell.isOn, isTrue())
    }

    // MARK: - VoIP

    func testVoIPSectionHeader() {
        let sut = makeSUT()

        let section = sut.voipSectionHeader()

        assertThat(section, presentAnd(equalTo(Strings.Setup.VoIPSection.title)))
    }

    func testAutomaticVoIPCell() throws {
        let config = makeConfig(voip: .automatic(strategy: .always))
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.automaticVoIPCell())

        assertThat(cell.title, presentAnd(equalTo(localizedString("setup.voip_automatic"))))
    }

    func testManualVoIPCell() throws {
        let config = makeConfig(voip: .manual(strategy: .always))
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.manualVoIPCell())

        assertThat(cell.title, presentAnd(equalTo(localizedString("setup.voip_manual"))))
    }

    func testDisableVoIPCell() throws {
        let config = makeConfig(voip: .disabled)
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.disabledVoIPCell())

        assertThat(cell.textLabel?.text, presentAnd(equalTo(localizedString("setup.voip_disabled"))))
    }

    func testDisableDirectIncomingCallsCell() throws {
        let config = makeConfig(disableDirectIncomingCalls: true, voip: .manual(strategy: .always))
        let sut = makeSUT(config: config)

        let cell = try unwrap(sut.disableDirectIncomingCallsCell())

        assertThat(cell.selectionStyle, equalTo(.none))
        assertThat(cell.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(cell.textLabel?.text, presentAnd(equalTo(localizedString("setup.voip_disable_direct_incoming_calls"))))
        assertThat(cell.onSwitchValueChange, present())
        assertThat(cell.`switch`?.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(cell.`switch`?.allTargets.count, equalTo(1))
        assertThat(cell.`switch`?.isOn, presentAnd(isTrue()))
    }

    // MARK: - Helpers

    private func makeSUT() -> AppSetupViewController {
        makeSUT(config: config)
    }

    private func makeSUT(config: Config) -> AppSetupViewController {
        let sut = AppSetupViewController(model: .init(config: config), services: ServicesFactoryStub())
        sut.loadViewIfNeeded()
        return sut
    }

    private func makeConfig(keys: Config.Keys = .any, disableDirectIncomingCalls: Bool = false, voip: Config.VoIP = .default) -> Config {
        .init(keys: keys, disableDirectIncomingCalls: disableDirectIncomingCalls, voip: voip)
    }

    private func localizedString(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}

private extension AppSetupViewController {

    private enum Section: Int {
        case region
        case environment
        case appId
        case apiKey
        case userDetails
        case tools
        case voip
    }

    // MARK: - Rows count

    func numberOfSections() -> Int {
        tableView.numberOfSections
    }

    func numberOfRowsInEnvironmentSection() -> Int {
        numberOfRowsInSection(.environment)
    }

    func numberOfRowsInRegionSection() -> Int {
        numberOfRowsInSection(.region)
    }

    func numberOfRowsInAppIdSection() -> Int {
        numberOfRowsInSection(.appId)
    }

    func numberOfRowsInApiKeySection() -> Int {
        numberOfRowsInSection(.apiKey)
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

    func appIdCell() -> TextFieldTableViewCell? {
        cellFor(row: 0, section: .appId) as? TextFieldTableViewCell
    }

    func apiKeyCell() -> TextFieldTableViewCell? {
        cellFor(row: 0, section: .apiKey) as? TextFieldTableViewCell
    }

    func regionCell(at index: Int) -> UITableViewCell? {
        cellFor(row: index, section: .region)
    }

    func environmentCell(at index: Int) -> UITableViewCell? {
        cellFor(row: index, section: .environment)
    }

    func userInfoCell() -> SwitchTableViewCell? {
        cellFor(row: 0, section: .userDetails) as? SwitchTableViewCell
    }

    func voipCell() -> UITableViewCell? {
        cellFor(row: 0, section: .voip)
    }

    // MARK: - VoIP

    func automaticVoIPCell() -> ExpandableTableViewCell? {
        cellFor(row: 0, section: .voip) as? ExpandableTableViewCell
    }

    func manualVoIPCell() -> ExpandableTableViewCell? {
        cellFor(row: 1, section: .voip) as? ExpandableTableViewCell
    }

    func disabledVoIPCell() -> UITableViewCell? {
        cellFor(row: 2, section: .voip)
    }

    func disableDirectIncomingCallsCell() -> SwitchTableViewCell? {
        cellFor(row: 3, section: .voip) as? SwitchTableViewCell
    }

    // MARK: - Headers

    func voipSectionHeader() -> String? {
        tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: Section.voip.rawValue)
    }

    func environmentSectionHeader() -> String? {
        tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: Section.environment.rawValue)
    }

    func regionSectionHeader() -> String? {
        tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: Section.region.rawValue)
    }

    private func cellFor(row: Int, section: Section) -> UITableViewCell? {
        cell(at: indexPath(row: row, section: section))
    }

    private func cell(at indexPath: IndexPath) -> UITableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }

    private func indexPath(row: Int, section: Section) -> IndexPath {
        IndexPath(row: row, section: section.rawValue)
    }

    func simulateIndiaRegionSelected() {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath(row: 1, section: .region))
    }
}
