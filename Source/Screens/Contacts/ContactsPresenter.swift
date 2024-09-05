// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

protocol ContactsPresenterOutput {
    func display(_ state: ContactsViewModel.State)
}

class ContactsPresenter {

    let output: ContactsPresenterOutput

    init(output: ContactsPresenterOutput) {
        self.output = output
    }

    func didStartLoading() {
        output.display(.loading)
    }

    func didFinishLoading(contacts: [Contact]) {
        output.display(.loaded(contacts))
    }

    func didFinishLoadingWithError(errorDescription: String) {
        output.display(.error(description: errorDescription))
    }
}

extension Weak: ContactsPresenterOutput where Object: ContactsPresenterOutput {

    func display(_ state: ContactsViewModel.State) {
        object?.display(state)
    }
}
