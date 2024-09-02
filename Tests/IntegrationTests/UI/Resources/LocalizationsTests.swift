// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraFoundation
@testable import SDK_Sample

final class LocalizationTests: UnitTestCase {

    private let bundle = Bundle(for: AppDelegate.self)
    private var table: LocalizationTable!

    override func setUp() {
        super.setUp()

        continueAfterFailure = true
        table = .defaultTable
    }

    override func tearDown() {
        table = nil

        super.tearDown()
    }

    func testThereIsALocalizationBundleForAllSupportedLocalizations() {
        let locales = bundle.localizations

        locales.forEach { locale in
            assertThat(makeLocalizableBundle(for: locale, in: bundle), describedAs("Could not find localization bundle for \(locale) localization", present()))
        }
    }

    func testThereIsLocalizationTableForAllSupportedLocalizations() {
        let allBundles = allLocalizableBundles(in: bundle)

        allBundles.forEach { locBundle in
            assertThat(loadContentsOfLocalizationTable(from: locBundle, table: table), describedAs("Could not load localization file \(table ?? "") from \(bundle) for locale \(locBundle.locale)", present()))
        }
    }

    func testThereIsALocalizationForAnyLocalizationKeyForAllSupportedLocalizations() {
        let allBundles = allLocalizableBundles(in: bundle)
        let allKeys = allLocalizationKeys(in: allBundles, table: table)

        allBundles.forEach { locBundle in
            allKeys.forEach { key in
                let localizedString = locBundle.bundle.localizedString(forKey: key, value: nil, table: table)
                assertThat(localizedString, describedAs("Missing \(Locale.current.localizedString(forLanguageCode: locBundle.locale) ?? "") language localized string for \(key) in table \(table ?? "")", not(equalTo(key))))
            }
        }
    }

    // MARK: - Helpers

    private typealias LocalizableBundle = (locale: String, path: String, bundle: Bundle)

    private func makeLocalizableBundle(for localization: String, in bundle: Bundle) -> LocalizableBundle? {
        guard let path = bundle.path(forResource: localization, ofType: "lproj"),
              let localizableBundle = Bundle(path: path) else {
                  return nil
              }

        return (localization, path, localizableBundle)
    }

    private func allLocalizableBundles(in bundle: Bundle) -> [LocalizableBundle] {
        bundle.localizations.filter({$0 != "Base"}).compactMap { loc in
            makeLocalizableBundle(for: loc, in: bundle)
        }
    }

    private func loadContentsOfLocalizationTable(from localizableBundle: LocalizableBundle, table: LocalizationTable) -> NSDictionary? {
        guard let path = localizableBundle.bundle.path(forResource: table, ofType: "strings") else {
            return nil
        }

        return NSDictionary(contentsOfFile: path)
    }

    private func loadContentsOfPluralizationTable(from localizableBundle: LocalizableBundle, table: LocalizationTable) -> NSDictionary? {
        guard let path = localizableBundle.bundle.path(forResource: table, ofType: "stringsdict") else {
            return nil
        }
        return NSDictionary(contentsOfFile: path)
    }

    private func allLocalizationKeys(in bundles: [LocalizableBundle], table: String) -> Set<String> {
        bundles.reduce([]) { (result, bundle) in
            let tableContents = loadContentsOfLocalizationTable(from: bundle, table: table) ?? NSDictionary()
            let keys = tableContents.allKeys as? [String] ?? []
            return result.union(Set(keys))
        }
    }

    private func allPluralizationKeys(in bundles: [LocalizableBundle], table: String) -> Set<String> {
        bundles.reduce([]) { (result, locBundle) in
            let tableContents = loadContentsOfPluralizationTable(from: locBundle, table: table) ?? NSDictionary()
            let keys = tableContents.allKeys as? [String] ?? []
            return result.union(Set(keys))
        }
    }

}
