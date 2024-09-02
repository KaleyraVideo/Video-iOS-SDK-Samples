// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ThemeViewControllerTests: UnitTestCase, ConditionalTestCase {
    func testSUTInitializationShouldSetupSelfCorrectly() {
        let sut = ThemeViewController(theme: AppTheme())

        sut.loadViewIfNeeded()

        assertThat(sut.title, presentAnd(equalTo(NSLocalizedString("settings.change_theme", comment: "Change theme"))))
    }

    func testThemeViewControllerShouldConfigureItselfWithTheme() {
        let sut = ThemeViewControllerSpy(theme: AppTheme())

        sut.loadViewIfNeeded()

        assertThat(sut.changed, equalTo(true))
    }

    func testSUTShouldSetUpChoosingLabelCorrectly() {
        let sut = ThemeViewController(theme: AppTheme())

        sut.loadViewIfNeeded()

        assertThat(sut.tableView(sut.tableView!, titleForHeaderInSection: 0), presentAnd(equalTo(NSLocalizedString("settings.choose.theme", comment: "Choose Theme"))))
    }

    func testSUTPresentsCorrectModeCasesInViewModel() {
        let sut = ThemeViewController(theme: AppTheme())

        sut.loadViewIfNeeded()
        guard let model = sut.viewModel?.datasource else { return }

        assertThat(model, hasCount(4))
    }

    func testSUTLayoutCycleShouldSetupTableViewCorrectly() {
        let sut = ThemeViewController(theme: AppTheme())

        sut.loadViewIfNeeded()

        assertThat(sut.tableView, present())
        assertThat(sut.tableView?.translatesAutoresizingMaskIntoConstraints, presentAnd(isFalse()))
        assertThat(sut.tableView?.dataSource as? ThemeViewController, present())
        assertThat(sut.tableView?.delegate as? ThemeViewController, present())
    }

    @available(iOS 13, *)
    func testSUTTableViewStyleIsInsetGroupedOnIos13AndHiger() throws {
        try run(ifVersionAtLeast: 13, "TableView insetGrouped style is only available on iOS 13 and higher", runnable: {
            let sut = ThemeViewController(theme: AppTheme())

            sut.loadViewIfNeeded()

            assertThat(sut.tableView, present())
            assertThat(sut.tableView?.style, presentAnd(equalTo(.insetGrouped)))
        })
    }

    func testSUTTableViewStyleIsGroupedOnIos12AndLower() throws {
        try run(ifVersionBelow: 13, "TableView insetGrouped style is only available on iOS 13 and higher", runnable: {
            let sut = ThemeViewController(theme: AppTheme())

            sut.loadViewIfNeeded()

            assertThat(sut.tableView, present())
            assertThat(sut.tableView?.style, presentAnd(equalTo(.grouped)))
        })
    }

    func testSUTTableViewShouldRegisterCellForSpecificIdentifier() {
        let sut = ThemeViewController(theme: AppTheme())

        sut.loadViewIfNeeded()
        let cell = sut.tableView?.dequeueReusableCell(withIdentifier: "themeTableViewCell")

        assertThat(cell, presentAnd(instanceOf(ThemeCell.self)))
    }

    func testThemeViewModelShouldInvokeSelectItemWhenTableViewIsTapped() {
        let sut = ThemeViewController(theme: AppTheme())
        let spy = ViewModelSpy()

        sut.loadViewIfNeeded()
        sut.viewModel = spy
        sut.tableView(sut.tableView!, didSelectRowAt: IndexPath(item: 0, section: 0))

        assertThat(spy.appTheme, present())
    }

    func testSelectedCellShouldSetCheckBoxAccessoryType() {
        let viewModel = ViewModelSpy()
        viewModel.datasource.first?.selected = true
        let sut = ThemeViewController(theme: AppTheme())

        sut.viewModel = viewModel
        sut.loadViewIfNeeded()
        assertThat(sut.tableView, present())
        let cell = sut.tableView(sut.tableView!, cellForRowAt: IndexPath(item: 0, section: 0))

        assertThat(cell.accessoryType, equalTo(.checkmark))
    }

    func testSelectedCellShouldDeselectAfterTap() {
        let viewModel = ViewModelSpy()
        let sut = ThemeViewController(theme: AppTheme())

        sut.viewModel = viewModel
        sut.loadViewIfNeeded()
        sut.tableView?.selectRow(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .none)
        sut.tableView(sut.tableView!, didSelectRowAt: IndexPath(item: 0, section: 0))
        let index = sut.tableView?.indexPathForSelectedRow

        assertThat(index, nilValue())
    }
}

private extension ThemeViewController {
    var tableView: UITableView? {
        view.firstDescendant()
    }
}

class ThemeViewControllerSpy: ThemeViewController{
    var changed = false
    override func themeChanged(theme: AppTheme) {
        changed = true
    }
}

private class ViewModelSpy: ThemeViewModelProtocol {

    var datasource: [AppTheme] = [AppTheme()]

    var flowDelegate: ThemeFlowDelegate?

    var appTheme: AppTheme?

    func selectItem(theme: AppTheme) {
        self.appTheme = theme
    }
}

#endif
