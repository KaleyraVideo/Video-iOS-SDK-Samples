// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class BaseCoordinatorTests: UnitTestCase {

    func testParentPropertyShouldBeStoredAsWeak() {
        let sut = makeSUT()
        var other: DummyCoordinator? = makeDummyCoordinator()
        sut.parent = other

        assertThat(sut.parent, present())

        other = nil

        assertThat(sut.parent, nilValue())
    }

    func testAddChildShouldAddTheProvidedChildToChildrenList() {
        let sut = makeSUT()
        let other = makeDummyCoordinator()

        sut.addChild(other)

        assertThat(sut.children, hasCount(1))
        assertThat(sut.children.first as? DummyCoordinator, presentAnd(sameInstance(other)))
    }

    func testAddChildShouldSetChildParent() {
        let sut = makeSUT()
        let other = makeDummyCoordinator()

        sut.addChild(other)

        assertThat(other.parent as? BaseCoordinator, presentAnd(sameInstance(sut)))
    }

    func testRemoveAllChildrenShouldRemoveAllAddedChildren() {
        let sut = makeSUT()
        let other1 = makeDummyCoordinator()
        let other2 = makeDummyCoordinator()

        sut.addChild(other1)
        sut.addChild(other2)
        sut.removeAllChildren()

        assertThat(sut.children, hasCount(0))
    }

    func testRemoveAllChildrenShouldSetParentPropertyToNilToAllRemovedChildren() {
        let sut = makeSUT()
        let other1 = makeDummyCoordinator()
        let other2 = makeDummyCoordinator()

        sut.addChild(other1)
        sut.addChild(other2)
        sut.removeAllChildren()

        assertThat(other1.parent, nilValue())
        assertThat(other2.parent, nilValue())
    }

    // MARK: - Events Default Implementation

    func testDefaultHandleFunctionCallShouldForwardFunctionCallToItsChild() {
        let sut = makeSUT()
        let child = makeCoordinatorSpy()

        sut.addChild(child)
        sut.handle(event: .shakeMotion, direction: .toChildren)

        assertThat(child.handleCalls, hasCount(1))
    }

    func testDefaultHandleFunctionCallWithToParentDirectionShouldForwardFunctionCallToItsParent() {
        let sut = makeSUT()
        let parent = makeCoordinatorSpy()

        sut.parent = parent
        sut.handle(event: .shakeMotion, direction: .toParent)

        assertThat(parent.handleCalls, hasCount(1))
    }

    // MARK: - Helpers

    private func makeSUT() -> BaseCoordinator {
        .init(services: ServicesFactoryStub())
    }

    private func makeDummyCoordinator() -> DummyCoordinator {
        .init()
    }

    private func makeCoordinatorSpy() -> CoordinatorSpy {
        .init()
    }
}
