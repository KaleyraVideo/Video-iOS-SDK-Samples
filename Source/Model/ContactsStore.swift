// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import Combine
import KaleyraVideoSDK

final class ContactsStore {

    private let repository: UserRepository

    @Published
    private(set) var contacts: [Contact] = []
    private(set) var hasLoaded: Bool = false

    var userDetailsProvider: UserDetailsProvider {
        ContactsUserDetailsProvider(contacts: contacts)
    }

    init(repository: UserRepository) {
        self.repository = repository
    }

    func load(_ completion: @escaping (Result<[Contact], Error>) -> Void) {
        guard !hasLoaded else {
            completion(.success(contacts))
            return
        }

        repository.loadUsers { [weak self] result in
            guard let self = self else { return }

            do {
                let contacts = Contact.makeRandomContacts(aliases: try result.get())
                self.contacts = contacts
                self.hasLoaded = true
                completion(.success(contacts))
            } catch {
                debugPrint("Could not load users \(error)")
                completion(.failure(error))
            }
        }
    }

    func update(contact: Contact) {
        guard let index = contacts.firstIndex(where: { $0.alias == contact.alias }) else {
            contacts.append(contact)
            return
        }

        contacts.remove(at: index)
        contacts.append(contact)
        contacts = contacts.sorted(by: { $0.alias.lowercased() < $1.alias.lowercased() })
    }
}
