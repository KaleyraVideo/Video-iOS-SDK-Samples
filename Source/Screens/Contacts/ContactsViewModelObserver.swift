// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

protocol ContactsViewModelObserver {
    func display(_ state: ContactsViewModel.State)
}

extension Weak: ContactsViewModelObserver where Object: ContactsViewModelObserver {

    func display(_ state: ContactsViewModel.State) {
        object?.display(state)
    }
}
