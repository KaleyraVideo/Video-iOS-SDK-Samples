// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

enum OperationState<T> {
    case loading
    case error(message: String)
    case finished(T)
}

protocol ContactsPresenterOutput {
    func display(_ state: OperationState<[Contact]>)
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
        output.display(.finished(contacts))
    }

    func didFinishLoadingWithError(errorDescription: String) {
        output.display(.error(message: errorDescription))
    }
}

extension Weak: ContactsPresenterOutput where Object: ContactsPresenterOutput {

    func display(_ state: OperationState<[Contact]>) {
        object?.display(state)
    }
}

extension OperationState: Equatable where T: Equatable {}
