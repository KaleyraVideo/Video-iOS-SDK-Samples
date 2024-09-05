// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

final class ContactsViewModelObserverSpy: ContactsViewModelObserver {

    private(set) lazy var displayInvocations = [ContactsViewModel.State]()

    func display(_ state: ContactsViewModel.State) {
        displayInvocations.append(state)
    }
}
