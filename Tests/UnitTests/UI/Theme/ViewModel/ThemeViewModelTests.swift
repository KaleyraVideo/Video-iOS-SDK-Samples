// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ThemeViewModelTests: UnitTestCase {

    private let suiteName = "test.ThemeViewModelTests.CustomString"

    func testThemeDataSourceModelIsInitializedWithParameters() throws {
        let themeStorage = try makeThemeStorage()
        let sut = ThemeViewModel(themeStorage: themeStorage)

        assertThat(sut.datasource, present())
        assertThat(sut.datasource.count, equalTo(4))
    }

    func testFlowDelegateShouldPushCustomThemeWhenCustomSelectItemIsTapped() {
        let spy = ThemeFlowDelegateSpy()
        let themeStorage = DummyThemeStorage()
        let sut = ThemeViewModel(themeStorage: themeStorage)
        let customAppTheme = AppTheme()
        customAppTheme.appearance = .custom

        sut.flowDelegate = spy
        sut.selectItem(theme: customAppTheme)

        assertThat(spy.appThemePassed, present())
        assertThat(spy.appThemePassed, presentAnd(equalTo(customAppTheme)))
    }

    func testThemeViewModelDataSourceContainElements() throws {
        let store = try makeThemeStorage()
        let sut = ThemeViewModel(themeStorage: store)

        assertThat(sut.datasource.count, presentAnd(equalTo(4)))
    }

    func testThemeViewModelDataSourceHasCompleteDatasource() throws {
        let store = try makeThemeStorage()
        let sut = ThemeViewModel(themeStorage: store)

        assertThat(sut.datasource[0].appearance, equalTo(.light))
        assertThat(sut.datasource[0].name, presentAnd(equalTo(NSLocalizedString("settings.light.mode", comment: ""))))

        assertThat(sut.datasource[1].appearance, equalTo(.dark))
        assertThat(sut.datasource[1].name, presentAnd(equalTo(NSLocalizedString("settings.dark.mode", comment: ""))))

        assertThat(sut.datasource[2].appearance, equalTo(.sand))
        assertThat(sut.datasource[2].name, presentAnd(equalTo(NSLocalizedString("settings.sand.mode", comment: ""))))

        assertThat(sut.datasource[3].appearance, equalTo(.custom))
        assertThat(sut.datasource[3].name, presentAnd(equalTo(NSLocalizedString("settings.custom.mode", comment: ""))))
    }

    func testSUTSelectItemShouldCallMethodInThemeStorageObject() {
        let store = ThemeStorageSpy()
        let sut = ThemeViewModel(themeStorage: store)
        let newSelectedAppTheme = AppTheme()
        newSelectedAppTheme.appearance = .light

        sut.selectItem(theme: newSelectedAppTheme)

        assertThat(store.saveThemeColorInvocations.count, equalTo(1))
    }

    func testSelectItemShouldCallNotifyThemeChangedOnItsFlowDelegate() {
        let sut = ThemeViewModel(themeStorage: DummyThemeStorage())
        let flowDelegateSpy = ThemeFlowDelegateSpy()
        let newSelectedAppTheme = AppTheme()

        sut.flowDelegate = flowDelegateSpy
        sut.selectItem(theme: newSelectedAppTheme)

        assertThat(flowDelegateSpy.notifyThemeChangedInvocations, hasCount(1))
    }

    // MARK: - Helpers

    private func makeThemeStorage() throws -> ThemeStorage {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UserDefaultError.cannotLoadSuite
        }

        return ThemeStorage(userDefaults: userDefaults)
    }
}

class ThemeStorageSpy: ThemeStorage {

    var getSavedThemeColorInvocations: [()] = []
    var saveThemeColorInvocations: [AppTheme] = []
    var getSelectedThemeInvocations: [()] = []
    var resetToDefaultValuesInvocations: [()] = []
    var themeSaved : AppTheme?

    func getThemeList() -> [AppTheme] {
        []
    }

    func save(theme: AppTheme) {
        self.themeSaved = theme
    }

    func select(theme: AppTheme) {
        saveThemeColorInvocations.append(theme)
    }

    func getSelectedTheme() -> AppTheme {
        getSelectedThemeInvocations.append(())
        return AppTheme()
    }

    func resetToDefaultValues() {
        resetToDefaultValuesInvocations.append(())
    }
}

class ThemeFlowDelegateSpy: ThemeFlowDelegate {

    var appThemePassed: AppTheme?
    var notifyThemeChangedInvocations: [()] = []

    func pushCustomThemeViewController(with theme: AppTheme) {
        appThemePassed = theme
    }

    func changeTheme(with theme: AppTheme) {

    }

    func notifyThemeChanged() {
        notifyThemeChangedInvocations.append(())
    }
}

#endif
