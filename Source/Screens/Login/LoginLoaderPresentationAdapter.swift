// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class LoginLoaderPresentationAdapter {

    private let presenter: ContactsPresenter
    private let store: ContactsStore
    private var contacts: [Contact] { store.contacts }

    init(store: ContactsStore, presenter: ContactsPresenter) {
        self.store = store
        self.presenter = presenter
    }

    func fetchUsers() {
        presenter.didStartLoading()

        store.load { [weak self] result in
            guard let self else { return }
            do {
                _ = try result.get()
                self.presenter.didFinishLoading(contacts: self.contacts)
            } catch {
                self.presenter.didFinishLoadingWithError(errorDescription: String(describing: error))
            }
        }
    }

    func filter(searchFilter: String) {
        guard searchFilter != "" else {
            presenter.didFinishLoading(contacts: contacts)
            return
        }

        let filteredContacts: [Contact] = contacts.filter({ element in
            element.alias.lowercased().contains(searchFilter.lowercased()) ? true : false
        })

        presenter.didFinishLoading(contacts: filteredContacts)
    }
}
