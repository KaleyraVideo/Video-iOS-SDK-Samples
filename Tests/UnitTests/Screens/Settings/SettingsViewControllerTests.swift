// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class SettingsViewControllerTests: UnitTestCase {

    private var sut: SettingsViewController!
    private var contact: Contact!
    private var config: Config!
    private var versions: Versions!
    private var delegate: DelegateSpy!
    private var store: ContactsStore!

    override func setUp() {
        super.setUp()

        delegate = .init()
        contact = Contact.makeRandomContact(alias: .alice)
        config = .init(keys: .any, environment: .development, region: .europe)
        versions = .init(app: .init(marketing: "2.2.1"), sdk: .init(marketing: "1.1.0"))
        store = .init(repository: UserRepositoryDummy())
        let services = ServicesFactoryStub()
        services.store = store
        sut = .init(user: contact, config: config, services: services, versions: versions)
        sut.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        contact = nil
        config = nil
        versions = nil
        store = nil
        sut = nil

        super.tearDown()
    }

    func testLoadViewShouldDisplayDetailsSection() {
        sut.loadViewIfNeeded()

        assertCell(sut.usernameCell, hasTitle: Strings.Settings.username, hasDetail: contact.alias)
        assertCell(sut.environmentCell, hasTitle: Strings.Settings.environment, hasDetail: "development")
        assertCell(sut.regionCell, hasTitle: Strings.Settings.region, hasDetail: "europe")
        assertCell(sut.appVersionCell, hasTitle: Strings.Settings.appVersion, hasDetail: "2.2.1")
        assertCell(sut.sdkVersionCell, hasTitle: Strings.Settings.sdkVersion, hasDetail: "1.1.0")
    }

    func testLoadViewShouldShowDisplaySettingsSectionWithLogoutRow() {
        sut.loadViewIfNeeded()

        assertThat(sut.logoutCell?.textLabel?.text, presentAnd(equalTo(Strings.Settings.logout)))
        assertThat(sut.logoutCell?.textLabel?.textAlignment, presentAnd(equalTo(.center)))
    }

    func testWhenContactIsUpdatedShouldUpdateTheUI() {
        sut.loadViewIfNeeded()

        let resourceURL = Bundle.main.url(forResource: "woman_0", withExtension: "jpg")!

        contact.imageURL = resourceURL
        store.update(contact: contact)

        let expectedImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "woman_0", ofType: "jpg")!)
        assertThat(sut.userImageView?.image?.jpegData(compressionQuality: 1), equalTo(expectedImage?.jpegData(compressionQuality: 1)))
    }

#if SAMPLE_CUSTOMIZABLE_THEME

    func testLoadViewShouldShowDisplaySettingsSectionWithChangeThemeRow() {
        sut.loadViewIfNeeded()

        assertThat(sut.changeThemeCell?.textLabel?.text, presentAnd(equalTo(Strings.Settings.changeTheme)))
        assertThat(sut.changeThemeCell?.detailTextLabel?.text, nilValue())
    }

#endif

    func testUserProfileImageViewFitItsContentsMaintainingTheAspectRatio() throws {
        sut.loadViewIfNeeded()

        let userImageView = try unwrap(sut.userImageView)
        assertThat(userImageView.clipsToBounds, isTrue())
        assertThat(userImageView.contentMode, equalTo(.scaleAspectFill))
    }

    func testLongPressOnCellShouldTriggerFlowDelegateMethod() throws {
        sut.loadViewIfNeeded()

        let userImageView = try unwrap(sut.userImageView)
        try userImageView.simulateLongPressRecognition()

        assertThat(delegate.updateUserInvocations, hasCount(1))
    }

    func testSelectLogoutShouldNotifyDelegate() throws {
        sut.loadViewIfNeeded()

        try sut.simulateLogoutTapped()

        assertThat(delegate.logoutInvocations, hasCount(1))
    }

#if SAMPLE_CUSTOMIZABLE_THEME

    func testFlowDelegateProtocolThemeOpenedMethodIsCalledWhenPresentThemeIsCalled() {
        sut.presentThemeViewController()

        assertThat(delegate.openThemeInvocations, hasCount(1))
    }

#endif

    func testViewDidDisappearShouldDeselectSelectedRow() {
        sut.loadViewIfNeeded()
        sut.tableView?.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        sut.viewDidDisappear(false)

        assertThat(sut.tableView?.indexPathForSelectedRow, not(present()))
    }

    // MARK: - Assertions

    private func assertCell(_ cell: UITableViewCell?,
                            hasTitle title: String,
                            hasDetail detail: String,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        assertThat(cell, present(), file: file, line: line)
        assertThat(cell?.textLabel?.text, presentAnd(equalTo(title)), file: file, line: line)
        assertThat(cell?.detailTextLabel?.text, presentAnd(equalTo(detail)), file: file, line: line)
    }

    // MARK: - Doubles

    private class DelegateSpy: SettingsViewControllerDelegate {

        private(set) lazy var openThemeInvocations: [Void] = []
        private(set) lazy var logoutInvocations: [Void] = []
        private(set) lazy var resetInvocations: [Void] = []
        private(set) lazy var updateUserInvocations = [Contact]()

        func settingsViewControllerDidLogout() {
            logoutInvocations.append()
        }

        func settingsViewControllerDidReset() {
            resetInvocations.append()
        }

        func settingsViewControllerDidUpdateUser(contact: SDK_Sample.Contact) {
            updateUserInvocations.append(contact)
        }

        func openTheme() {
            openThemeInvocations.append()
        }
    }
}

private extension SettingsViewController {

    private struct TableViewNotFoundError: Error {}

    var tableView: UITableView? {
        guard isViewLoaded else { return nil }

        return view.firstDescendant()
    }

    var userImageView: UIImageView? {
        guard let table = tableView else { return nil }

        let header = table.delegate?.tableView?(table, viewForHeaderInSection: 0)
        return header?.firstDescendant()
    }

    var usernameCell: UITableViewCell? {
        cellForRow(at: IndexPath(row: 0, section: 0))
    }

    var environmentCell: UITableViewCell? {
        cellForRow(at: IndexPath(row: 1, section: 0))
    }

    var regionCell: UITableViewCell? {
        cellForRow(at: IndexPath(row: 2, section: 0))
    }

    var appVersionCell: UITableViewCell? {
        cellForRow(at: IndexPath(row: 3, section: 0))
    }

    var sdkVersionCell: UITableViewCell? {
        cellForRow(at: IndexPath(row: 4, section: 0))
    }

    var logoutCell: UITableViewCell? {
        cellForRow(at: logoutRowIndexPath)
    }

    var changeThemeCell: UITableViewCell? {
#if SAMPLE_CUSTOMIZABLE_THEME
        cellForRow(at: IndexPath(row: 0, section: 1))
#else
        nil
#endif
    }

    private var logoutRowIndexPath: IndexPath {
#if SAMPLE_CUSTOMIZABLE_THEME
        IndexPath(row: 1, section: 1)
#else
        IndexPath(row: 0, section: 1)
#endif
    }

    func simulateLogoutTapped() throws {
        guard let table = tableView else { throw TableViewNotFoundError() }

        table.delegate?.tableView?(table, didSelectRowAt: logoutRowIndexPath)
    }

    private func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        guard let table = tableView else { return nil }

        return table.dataSource?.tableView(table, cellForRowAt: indexPath)
    }
}
