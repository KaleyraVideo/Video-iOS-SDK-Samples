// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

final class TextFieldTableViewCellTests: UnitTestCase {

    private var sut: TextFieldTableViewCell!

    override func setUpWithError() throws {
        try super.setUpWithError()

        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil

        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testSelectionStyleIsNone() {
        assertThat(sut.selectionStyle, equalTo(.none))
    }

    func testAddTextFieldToContentView() {
        let field = sut.textField

        assertThat(field, present())
        assertThat(field?.isDescendant(of: sut.contentView), presentAnd(isTrue()))
    }

    func testAddToolbarAsTextFieldInputAccessoryViewContainingDoneButton() throws {
        let field = sut.textField

        let toolbar = try unwrap(field?.inputAccessoryView as? UIToolbar)

        assertThat(toolbar.items, presentAnd(hasCount(2)))
    }

    func testSetTextShouldUpdateFieldText() {
        sut.text = "some text"

        assertThat(sut.textField?.text, presentAnd(equalTo("some text")))
    }

    func testGetTextShouldGetTextFieldText() {
        sut.textField?.text = "some text"

        assertThat(sut.text, presentAnd(equalTo("some text")))
    }

    func testTintColorShouldBeThemeSecondaryColor() {
        assertThat(sut.tintColor, equalTo(Theme.Color.secondary))
    }

    func testOnTextFieldTextChangedShouldNotifyObserver() {
        let observer = makeObserver()
        sut.onTextChanged = observer.callAsFunction(_:)

        sut.simulateTextChanged("new text")

        assertThat(observer.invocations, equalTo(["new text"]))
    }

    func testOnTextEditingEndedShouldNotifyObserver() {
        let observer = makeObserver()
        sut.onTextChanged = observer.callAsFunction(_:)

        sut.simulateTextEditingEnded("new text")

        assertThat(observer.invocations, equalTo(["new text"]))
    }

    func testReuseIdentifierShouldClearFieldText() {
        sut.text = "text"

        sut.prepareForReuse()

        assertThat(sut.text, equalTo(""))
    }

    // MARK: - Helpers

    private func makeObserver() -> CompletionSpy<String?> {
        .init()
    }

}
