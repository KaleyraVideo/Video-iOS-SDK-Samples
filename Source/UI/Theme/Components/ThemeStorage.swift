// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

#if SAMPLE_CUSTOMIZABLE_THEME

protocol ThemeStorage {
    func getThemeList() -> [AppTheme]
    func save(theme: AppTheme)
    func select(theme: AppTheme)
    func getSelectedTheme() -> AppTheme
    func resetToDefaultValues()
}

class UserDefaultsThemeStorage: ThemeStorage {

    private var themeList: [AppTheme]?

    func getThemeList() -> [AppTheme] {
        if let themeList = themeList, !themeList.isEmpty {
            return themeList
        }

        guard let data = userDefaults.data(forKey: themeListUserDefaultKey) else {
            return saveDefaultThemeListToLocalVariableAndReturn()
        }

        guard let list = try? JSONDecoder().decode([AppTheme].self, from: data) else {
            return saveDefaultThemeListToLocalVariableAndReturn()
        }

        guard !list.isEmpty else {
            return saveDefaultThemeListToLocalVariableAndReturn()
        }

        return saveThemeListToLocalVariableAndReturn(list)
    }

    private func saveDefaultThemeListToLocalVariableAndReturn() -> [AppTheme] {
        let defaultList = getDefaultAppThemeList()
        return saveThemeListToLocalVariableAndReturn(defaultList)
    }

    private func saveThemeListToLocalVariableAndReturn(_ list: [AppTheme]) -> [AppTheme] {
        themeList = list
        return list
    }

    private func getDefaultAppThemeList() -> [AppTheme] {
        let light = AppTheme.defaultLightTheme()
        light.selected = true

        let dark = AppTheme.defaultDarkTheme()

        let sand = AppTheme.defaultSandTheme()

        let custom = AppTheme.defaultCustomTheme()

        return [light, dark, sand, custom]
    }

    func save(theme: AppTheme) {
        var list = getThemeList()
        if let index = list.firstIndex(of: theme) {
            list[index] = theme
        }

        guard let data = try? JSONEncoder().encode(list) else { return }

        userDefaults.set(data, forKey: themeListUserDefaultKey)

    }

    func select(theme: AppTheme) {
        deselectOld()
        selectNew(theme)
    }

    private func deselectOld() {
        getSelectedTheme().selected = false
    }

    private func selectNew(_ theme: AppTheme) {
        theme.selected = true
        save(theme: theme)
    }

    func getSelectedTheme() -> AppTheme {
        let list = getThemeList()

        guard let selected = list.first(where: { $0.selected }) else {
            selectNew(list[0])
            return list[0]
        }

        return selected
    }

    func resetToDefaultValues() {
        userDefaults.removeObject(forKey: themeListUserDefaultKey)
        _ = saveDefaultThemeListToLocalVariableAndReturn()
    }

    let userDefaults: UserDefaults
    private let themeListUserDefaultKey = "__saved_theme_list__"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}
#endif
