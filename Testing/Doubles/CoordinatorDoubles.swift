// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

class DummyCoordinator: Coordinator {

    var parent: Coordinator?
    fileprivate(set) var children: [Coordinator] = []

    func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool { false }

    func addChild(_ coordinator: Coordinator) {
        children.append(coordinator)
    }

    func removeChild(_ child: Coordinator) {
        children.removeAll(where: { child === $0 })
    }

    func removeAllChildren() {
        children.removeAll()
    }
}

class CoordinatorSpy: DummyCoordinator {

    var handleCalls: [Void] {
        handleCallsWithParams.map({ _ in () })
    }

    private(set) var handleCallsWithParams: [(CoordinatorEvent, EventDirection)] = []

    override func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool {
        handleCallsWithParams.append((event, direction))
        return super.handle(event: event, direction: direction)
    }
}
