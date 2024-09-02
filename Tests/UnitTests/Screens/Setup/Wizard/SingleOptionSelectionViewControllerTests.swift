// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import UIKit
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class SingleOptionSelectionViewControllerTests: UnitTestCase {

    func testDisplaysAsManyRowsAsTheAvailableOptions() {
        let sut = makeSUT(options: Option.allCases)

        assertThat(sut.numberOfRows, equalTo(Option.allCases.count))
    }

    func testDisplaysFirstOptionAsSelected() {
        let sut = makeSUT(options: [.first, .second])

        assertThat(sut.cellForRow(atIndex: 0)?.accessoryType, presentAnd(equalTo(UITableViewCell.AccessoryType.checkmark)))
        assertThat(sut.cellForRow(atIndex: 1)?.accessoryType, presentAnd(equalTo(UITableViewCell.AccessoryType.none)))
    }

    func testDisplaysLocalizedNameForEachOptionInItsCell() {
        let sut = makeSUT(options: Option.allCases)

        assertThat(sut.cellForRow(atIndex: 0)?.textLabel?.text, presentAnd(equalTo("First")))
        assertThat(sut.cellForRow(atIndex: 1)?.textLabel?.text, presentAnd(equalTo("Second")))
        assertThat(sut.cellForRow(atIndex: 2)?.textLabel?.text, presentAnd(equalTo("Third")))
        assertThat(sut.cellForRow(atIndex: 3)?.textLabel?.text, presentAnd(equalTo("Fourth")))
    }

    func testOnCellSelectionReloadRow() {
        let sut = makeSUT(options: [.first, .second])

        sut.simulateCellSelection(atIndex: 1)

        assertThat(sut.cellForRow(atIndex: 1)?.accessoryType, presentAnd(equalTo(UITableViewCell.AccessoryType.checkmark)))
    }

    func testOnCellSelectedShouldNotifyDelegate() {
        let sut = makeSUT(options: [.first, .second])

        let completion = CompletionSpy<Option>()
        sut.onSelection = completion.callAsFunction(_:)
        sut.simulateCellSelection(atIndex: 1)

        assertThat(completion.invocations, equalTo([.second]))
    }

    // MARK: - Helpers

    private func makeSUT(options: [Option]) -> SingleChoiceSelectionViewController<Option> {
        let sut = SingleChoiceSelectionViewController(options: options, presenter: Presenter().localizedName(_:))
        sut.loadViewIfNeeded()
        return sut
    }

    private enum Option: CaseIterable {
        case first
        case second
        case third
        case fourth
    }

    private struct Presenter {

        func localizedName(_ option: Option) -> String {
            switch option {
                case .first:
                    return "First"
                case .second:
                    return "Second"
                case .third:
                    return "Third"
                case .fourth:
                    return "Fourth"
            }
        }
    }
}

private extension SingleChoiceSelectionViewController {

    var numberOfRows: Int {
        tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? -1
    }

    func cellForRow(atIndex index: Int) -> UITableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: .init(row: index, section: 0))
    }

    func simulateCellSelection(atIndex index: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: .init(row: index, section: 0))
    }
}
