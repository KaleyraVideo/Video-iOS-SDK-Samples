// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class ContactsViewModel {

    private let store: ContactsStore
    private let presenter: ContactsPresenter
    private let loggedUser: String?

    var contacts: [Contact] { store.contacts }

    init(presenter: ContactsPresenter, store: ContactsStore, loggedUser: String? = nil) {
        self.presenter = presenter
        self.store = store
        self.loggedUser = loggedUser
    }

    func fetchUsers() {
        presenter.didStartLoading()
        store.load { [weak self] result in
            guard let self else { return }

            do {
                _ = try result.get()
                self.presenter.didFinishLoading(contacts: self.filterLoggedUser(from: self.contacts))
            } catch {
                self.presenter.didFinishLoadingWithError(errorDescription: String(describing: error))
            }
        }
    }

    func update(contact: Contact) {
        store.update(contact: contact)
        presenter.didFinishLoading(contacts: filterLoggedUser(from: contacts))
    }

    func filter(searchFilter: String) {
        guard searchFilter != "" else {
            presenter.didFinishLoading(contacts: filterLoggedUser(from: contacts))
            return
        }

        let filteredContacts: [Contact] = contacts.filter({ element in
            element.alias.lowercased().contains(searchFilter.lowercased()) ? true : false
        })

        presenter.didFinishLoading(contacts: filterLoggedUser(from: filteredContacts))
    }

    private func filterLoggedUser(from contacts: [Contact]) -> [Contact] {
        guard let loggedUser else { return contacts }
        return contacts.filter { $0.alias != loggedUser }
    }
}
