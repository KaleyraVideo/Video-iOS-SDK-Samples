// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

final class ContactsViewModel {

    enum State: Equatable {
        case initial
        case loading
        case error(description: String)
        case loaded([Contact])

        var isLoading: Bool {
            self == .loading
        }

        var isLoaded: Bool {
            guard case State.loaded = self else { return false }
            return true
        }

        var contacts: [Contact] {
            guard case State.loaded(let contacts) = self else { return [] }
            return contacts
        }
    }

    private let store: ContactsStore
    private let observer: ContactsViewModelObserver
    private let loggedUser: String?
    private var filter: String?

    private(set) var state: State = .initial {
        didSet {
            observer.display(state)
        }
    }

    var contacts: [Contact] { store.contacts }

    init(observer: ContactsViewModelObserver, store: ContactsStore, loggedUser: String? = nil) {
        self.observer = observer
        self.store = store
        self.loggedUser = loggedUser
    }

    func load() {
        guard !state.isLoading, !state.isLoaded else { return }

        state = .loading
        store.load { [weak self] result in
            guard let self else { return }

            do {
                _ = try result.get()
                self.state = .loaded(self.filterLoggedUser(from: self.contacts))
            } catch {
                self.state = .error(description: String(describing: error))
            }
        }
    }

    func update(contact: Contact) {
        store.update(contact: contact)
    }

    func filter(searchFilter: String) {
        filter = searchFilter != "" ? searchFilter : nil

        guard state.isLoaded else { return }

        state = .loaded(filterLoggedUser(from: filter.map({ contacts.filterBy(aliasPattern: $0)}) ?? contacts))
    }

    private func filterLoggedUser(from contacts: [Contact]) -> [Contact] {
        guard let loggedUser else { return contacts }
        return contacts.filter { $0.alias != loggedUser }
    }
}

private extension Array where Element == Contact {

    func filterBy(aliasPattern pattern: String) -> [Contact] {
        filter {
            $0.alias.lowercased().contains(pattern.lowercased()) ? true : false
        }
    }
}
