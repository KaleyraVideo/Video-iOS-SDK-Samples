// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

class BaseCoordinator: NSObject, Coordinator {

    weak var parent: Coordinator?
    private(set) var children: [Coordinator] = []
    let services: ServicesFactory

    init(services: ServicesFactory) {
        self.services = services
    }

    func addChild(_ coordinator: Coordinator) {
        coordinator.parent = self
        children.append(coordinator)
    }

    func removeChild(_ child: Coordinator) {
        guard children.contains(where: { $0 === child }) else { return }

        children.removeAll(where: { $0 === child })
        child.parent = nil
    }

    func removeAllChildren() {
        removeAllChildrenParent()
        children.removeAll()
    }

    private func removeAllChildrenParent() {
        for (index, _) in children.enumerated() {
            children[index].parent = nil
        }
    }

    @discardableResult
    func handle(event: CoordinatorEvent, direction: EventDirection) -> Bool {
        switch direction {
            case .toParent:
                return parent?.handle(event: event, direction: direction) ?? false
            case .toChildren:
                for element in children {
                    let handled = element.handle(event: event, direction: direction)
                    guard handled else { continue }
                    return true
                }
        }
        return false
    }
}
