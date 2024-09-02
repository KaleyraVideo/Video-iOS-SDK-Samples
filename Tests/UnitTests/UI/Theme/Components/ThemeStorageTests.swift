// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class ThemeStorageTests: UnitTestCase {

    private let suiteName = "test.ThemeStorageTest.CustomString"
    private let themeKey = "__saved_theme_list__"

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testGetThemeListReturnADefaultListWhenValueIsNotPresent() throws {
        let (sut, _) = try makeSUT()
        let themeList = sut.getThemeList()

        assertThat(themeList, hasCount(4))
        assertThat(themeList[0].appearance, equalTo(.light))
        assertThat(themeList[1].appearance, equalTo(.dark))
        assertThat(themeList[2].appearance, equalTo(.sand))
        assertThat(themeList[3].appearance, equalTo(.custom))
    }

    func testGetThemeListReturnThePreviouslySavedList() throws {
        let (sut, userDef) = try makeSUT()

        try saveDummyAppThemeList(userDef)
        let themeList = sut.getThemeList()

        assertThat(themeList, hasCount(2))
        assertThat(themeList[0].appearance, equalTo(.sand))
        assertThat(themeList[1].appearance, equalTo(.dark))
    }

    func testGetThemeListGetTheValueFromUserDefaultOnlyTheFirstTimeKeepingInMemoryThePreviouslyGotValue() throws {
        let (sut, userDef) = try makeSUT()

        var themeList = sut.getThemeList()
        try saveDummyAppThemeList(userDef)
        themeList = sut.getThemeList()

        assertThat(themeList, hasCount(4))
        assertThat(themeList[0].appearance, equalTo(.light))
        assertThat(themeList[1].appearance, equalTo(.dark))
        assertThat(themeList[2].appearance, equalTo(.sand))
        assertThat(themeList[3].appearance, equalTo(.custom))
    }

    func testSaveThemeShouldSaveTheProvidedThemeInTheUserDefaults() throws {
        let (sut, userDef) = try makeSUT()

        let themeList = sut.getThemeList()
        let theme = themeList[1]
        theme.selected = true
        sut.save(theme: theme)
        let listFromUserDefaults = try getListFromUserDefault(userDef)
        let themeAfter = listFromUserDefaults.first(where: { $0.id == theme.id })

        assertThat(themeAfter?.selected, presentAnd(isTrue()))
    }

    func testGetSelectedThemeShouldReturnTheSelectedTheme() throws {
        let (sut, userDef) = try makeSUT()

        try saveDummyAppThemeList(userDef)
        let list = sut.getThemeList()
        let selected = list.first(where: { $0.selected })
        let sutSelected = sut.getSelectedTheme()

        assertThat(selected, presentAnd(sameInstance(sutSelected)))
    }

    func testSelectThemeFunctionShouldChangeTheSelectionOfThePassedThemeToTrue() throws {
        let (sut, _) = try makeSUT()
        let themeList = sut.getThemeList()
        let themeToSelect = themeList[2]

        assertThat(themeToSelect.selected, isFalse())

        sut.select(theme: themeToSelect)

        assertThat(themeToSelect.selected, isTrue())
    }

    func testSelectThemeFunctionShouldChangeTheSelectionOfPreviouSelectedThemeToFalse() throws {
        let (sut, _) = try makeSUT()
        let themeList = sut.getThemeList()
        let themeToSelect = themeList[2]
        let previouslySelected = sut.getSelectedTheme()

        assertThat(previouslySelected.selected, isTrue())

        sut.select(theme: themeToSelect)

        assertThat(previouslySelected.selected, isFalse())
    }

    func testNoSelectedThemeInStorageShouldReturnAsSelectedThemeTheFirstThemeOfTheList() throws {
        let (sut, userDef) = try makeSUT()
        let firstTheme = AppTheme()
        firstTheme.appearance = .sand
        firstTheme.selected = false
        let secondTheme = AppTheme()
        secondTheme.appearance = .dark
        secondTheme.selected = false
        let  list = [firstTheme, secondTheme]

        try saveDummyAppThemeList(list, userDef)

        assertThat(sut.getSelectedTheme().appearance, equalTo(ThemeAppearance.sand))
    }

    func testgetDefaultAppThemeListShouldReturnDefaultThemeList() throws {
        let (sut, userDef) = try makeSUT()

        let themeList = sut.getThemeList()

        assertThat(themeList.first?.appearance, equalTo(.light))
        assertThat(themeList[1].appearance, equalTo(.dark))
        assertThat(themeList[2].appearance, equalTo(.sand))
        assertThat(themeList[3].appearance, equalTo(.custom))
    }

    // MARK: - Helpers

    private func makeSUT() throws -> (ThemeStorage, UserDefaults) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UserDefaultError.cannotLoadSuite
        }

        return (ThemeStorage(userDefaults: userDefaults), userDefaults)
    }

    private func saveDummyAppThemeList(_ userDefaults: UserDefaults) throws {
        let firstTheme = AppTheme()
        firstTheme.appearance = .sand

        let secondTheme = AppTheme()
        secondTheme.selected = true
        secondTheme.appearance = .dark

        let  list = [firstTheme, secondTheme]

        try saveDummyAppThemeList(list, userDefaults)
    }

    private func saveDummyAppThemeList(_ list: [AppTheme], _ userDefaults: UserDefaults) throws {
        let data = try JSONEncoder().encode(list)
        userDefaults.set(data, forKey: themeKey)
    }

    private func getListFromUserDefault(_ userDefaults: UserDefaults) throws -> [AppTheme] {
        guard let data = userDefaults.data(forKey: themeKey) else {
            throw ListNotFoundError()
        }

        let list = try JSONDecoder().decode([AppTheme].self, from: data)
        return list
    }

    func testResetThemeShouldClearSavedThemeListAndReplaceItWithTheDefaultOne() throws {
        let (sut, userDef) = try makeSUT()

        try saveDummyAppThemeList(userDef)
        sut.resetToDefaultValues()
        let themeList = sut.getThemeList()

        assertThat(themeList, hasCount(4))
        assertThat(themeList[0].appearance, equalTo(.light))
        assertThat(themeList[1].appearance, equalTo(.dark))
        assertThat(themeList[2].appearance, equalTo(.sand))
        assertThat(themeList[3].appearance, equalTo(.custom))
    }

    private struct ListNotFoundError: Error { }
}

enum UserDefaultError: Error {
    case cannotLoadSuite
}

#endif
