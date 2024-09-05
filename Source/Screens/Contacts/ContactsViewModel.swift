// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import Combine

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
    private let loggedUser: String?
    private var filter: String?

    var observer: ContactsViewModelObserver?

    @Published
    private(set) var state: State = .initial {
        didSet {
            observer?.display(state)
        }
    }

    private lazy var subscriptions = Set<AnyCancellable>()

    init(store: ContactsStore, loggedUser: String? = nil) {
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
                self.store.$contacts.dropFirst().sink { [weak self] contacts in
                    self?.setContacts(contacts: contacts)
                }.store(in: &self.subscriptions)
                self.setContacts(contacts: store.contacts)
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

        setContacts(contacts: store.contacts)
    }

    private func setContacts(contacts: [Contact]) {
        state = .loaded(contacts.filterBy(loggedUser: loggedUser, aliasPattern: filter))
    }
}

private extension Array where Element == Contact {

    func filterBy(aliasPattern pattern: String?) -> [Contact] {
        pattern.map { filterBy(aliasPattern: $0) } ?? self
    }

    func filterBy(aliasPattern pattern: String) -> [Contact] {
        filter {
            $0.alias.lowercased().contains(pattern.lowercased()) ? true : false
        }
    }

    func filterBy(alias: String) -> [Contact] {
        filter { $0.alias != alias }
    }

    func filter(loggedUser: String?) -> [Contact] {
        loggedUser.map({ filterBy(alias: $0) }) ?? self
    }

    func filterBy(loggedUser: String?, aliasPattern pattern: String?) -> [Contact] {
        filter(loggedUser: loggedUser).filterBy(aliasPattern: pattern)
    }
}
