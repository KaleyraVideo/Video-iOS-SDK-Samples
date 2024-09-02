// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation

protocol UserRepository {
    typealias ResultContacts = Swift.Result<[String], Error>

    func loadUsers(completion: @escaping (ResultContacts) -> Void)
}

extension UserRepository {

    func mainDecorator() -> UserRepository {
        MainQueueDispatchDecorator(decoratee: self)
    }
}
