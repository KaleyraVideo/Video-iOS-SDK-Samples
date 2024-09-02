// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

#if SAMPLE_CUSTOMIZABLE_THEME

protocol ThemeViewModelProtocol {
    var datasource: [AppTheme] { get }
    var flowDelegate: ThemeFlowDelegate? { get }
    func selectItem(theme: AppTheme)
}

protocol ThemeChangedNotifier {
    func notifyThemeChanged()
}

protocol ThemeFlowDelegate: ThemeChangedNotifier {
    func pushCustomThemeViewController(with theme: AppTheme)
}

class ThemeViewModel: ThemeViewModelProtocol {

    var flowDelegate: ThemeFlowDelegate?

    private(set) var selected: AppTheme?

    private let themeStorage: ThemeStorage

    lazy var datasource: [AppTheme] = {
        themeStorage.getThemeList()
    }()

    init(themeStorage: ThemeStorage) {
        self.themeStorage = themeStorage
    }

    func selectItem(theme: AppTheme) {
        themeStorage.select(theme: theme)
        if theme.appearance == .custom {
            flowDelegate?.pushCustomThemeViewController(with: theme)
        }
        flowDelegate?.notifyThemeChanged()
    }
}

#endif
