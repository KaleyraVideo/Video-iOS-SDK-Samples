// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

#if SAMPLE_CUSTOMIZABLE_THEME

class DummyThemeStorage: ThemeStorage {

    func getThemeList() -> [AppTheme] {
        []
    }

    func save(theme: AppTheme) { }

    func select(theme: AppTheme) { }

    func getSelectedTheme() -> AppTheme {
        AppTheme()
    }

    func resetToDefaultValues() { }
}

#endif
