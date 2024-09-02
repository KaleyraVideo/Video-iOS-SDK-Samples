// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class CallOptionsTableViewControllerTests: UnitTestCase {

    private var sut: CallOptionsTableViewController!

    override func setUp() {
        super.setUp()

        sut = .init(options: CallOptions(), services: ServicesFactoryStub())
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testTitle() {
        sut.loadViewIfNeeded()

        assertThat(sut.title, equalTo(Strings.CallSettings.title))
    }

    func testTableViewStyle() {
        assertThat(sut.tableView.style, equalTo(.insetGrouped))
    }

    func testDataSourceForTableViewSectionsAndCells() {
        sut.loadViewIfNeeded()

        assertThat(sut.numberOfSections(), equalTo(6))
        assertThat(sut.numberOfRowsIn(section: .callType), equalTo(3))
        assertThat(sut.numberOfRowsIn(section: .recording), equalTo(3))
        assertThat(sut.numberOfRowsIn(section: .duration), equalTo(1))
        assertThat(sut.numberOfRowsIn(section: .group), equalTo(1))
        assertThat(sut.numberOfRowsIn(section: .rating), equalTo(1))
        assertThat(sut.numberOfRowsIn(section: .presentationMode), equalTo(2))
    }

    func testCellForRowForDurationRowShouldSetATextFieldAsCellAccessoryView() throws {
        sut.loadViewIfNeeded()

        let cell = sut.callDurationCell()

        assertThat(cell, present())
        assertThat(cell?.selectionStyle, presentAnd(equalTo(.none)))
        assertThat(cell?.tintColor.cgColor, presentAnd(equalTo(Theme.Color.secondary.cgColor)))

        let durationTextField = try unwrap(cell?.textField)

        assertThat(durationTextField.textAlignment, equalTo(.natural))
        assertThat(durationTextField.inputAccessoryView, present())

        let toolBar: UIToolbar = try unwrap(durationTextField.inputAccessoryView as? UIToolbar)

        assertThat(toolBar.frame, equalTo(CGRect(x: 0, y: 0, width: 100, height: 44)))
        assertThat(toolBar.barStyle, equalTo(.default))
        assertThat(toolBar.items?.count, presentAnd(equalTo(2)))

        let doneButtonItem = try unwrap(toolBar.items?.last)

        assertThat(doneButtonItem.style, equalTo(.plain))
        assertThat(doneButtonItem.title, equalTo(Strings.CallSettings.confirm))
    }

    func testSetupRecordingTypeCell() throws {
        sut.loadViewIfNeeded()

        let cell = sut.recordingCell()

        assertThat(cell?.selectionStyle, presentAnd(equalTo(.none)))
        assertThat(cell?.tintColor.cgColor, equalTo(Theme.Color.secondary.cgColor))
    }

    func testCellForRowForGroupCallRowShouldSetSwitchAsCellAccessoryView() throws {
        sut.loadViewIfNeeded()

        let cell = sut.groupCell()

        assertThat(cell, present())
        assertThat(cell?.selectionStyle, presentAnd(equalTo(.none)))
        assertThat(cell?.tintColor.cgColor, presentAnd(equalTo(Theme.Color.secondary.cgColor)))

        let `switch` = try XCTUnwrap(cell?.accessoryView as? UISwitch)

        assertThat(`switch`.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(`switch`.allTargets.count, equalTo(1))
    }

    func testCellForRowForRatingRowShouldSetSwitchAsCellAccessoryView() throws {
        sut.loadViewIfNeeded()

        let cell = sut.ratingCell()

        assertThat(cell, present())
        assertThat(cell?.selectionStyle, presentAnd(equalTo(.none)))
        assertThat(cell?.tintColor.cgColor, presentAnd(equalTo(Theme.Color.secondary.cgColor)))

        let `switch` = try XCTUnwrap(cell?.accessoryView as? UISwitch)

        assertThat(`switch`.onTintColor?.cgColor, equalTo(Theme.Color.secondary.cgColor))
        assertThat(`switch`.allTargets.count, equalTo(1))
    }

    func testOnDismissFunctionReturnUpdatedCallOptionsItem() throws {
        sut.loadViewIfNeeded()

        var callOptionsItem = CallOptions()
        let onDismiss: (CallOptions) -> Void = { options in
            callOptionsItem = options
        }

        sut.onDismiss = onDismiss

        sut.simulateRowSelectedAt(1, inSection: .callType)

        let cellTextField = sut.callDurationCell()
        cellTextField?.simulateTextChanged("100")

        let groupCallCell = sut.groupCell()
        let groupCallSwitch = try XCTUnwrap(groupCallCell?.accessoryView as? UISwitch)

        groupCallSwitch.isOn = true
        groupCallSwitch.simulate(event: UIControl.Event.valueChanged)

        let ratingCell = sut.ratingCell()
        let ratingSwitch = try XCTUnwrap(ratingCell?.accessoryView as? UISwitch)

        ratingSwitch.isOn = true
        ratingSwitch.simulate(event: UIControl.Event.valueChanged)

        sut.viewWillDisappear(false)

        XCTAssertEqual(callOptionsItem.recording, .none)
        XCTAssertEqual(callOptionsItem.maximumDuration, 100)
        XCTAssertEqual(callOptionsItem.type, .audioUpgradable)
        XCTAssertEqual(callOptionsItem.isGroup, true)
        XCTAssertEqual(callOptionsItem.showsRating, true)
    }

    func testTableViewContentInsetHasABottomPadding() {
        sut.loadViewIfNeeded()

        assertThat(sut.tableView?.contentInset.top, equalTo(0))
        assertThat(sut.tableView?.contentInset.left, equalTo(0))
        assertThat(sut.tableView?.contentInset.right, equalTo(0))
        assertThat(sut.tableView?.contentInset.bottom, equalTo(20))
    }
}

private extension CallOptionsTableViewController {

    enum Section: Int {
        case callType
        case recording
        case duration
        case group
        case rating
        case presentationMode
    }

    func numberOfSections() -> Int {
        tableView.numberOfSections
    }

    func numberOfRowsIn(section: Section) -> Int {
        tableView.numberOfRows(inSection: section.rawValue)
    }

    func recordingCell() -> UITableViewCell? {
        cellForRow(at: 0, section: .recording)
    }

    func callDurationCell() -> TextFieldTableViewCell? {
        cellForRow(at: 0, section: .duration) as? TextFieldTableViewCell
    }

    func groupCell() -> UITableViewCell? {
        cellForRow(at: 0, section: .group)
    }

    func ratingCell() -> UITableViewCell? {
        cellForRow(at: 0, section: .rating)
    }

    private func cellForRow(at rowIndex: Int, section: Section) -> UITableViewCell? {
        tableView(tableView, cellForRowAt: IndexPath(row: rowIndex, section: section.rawValue))
    }

    func simulateRowSelectedAt(_ rowIndex: Int, inSection section: Section) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: rowIndex, section: section.rawValue))
    }
}
