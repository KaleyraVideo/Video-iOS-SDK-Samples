// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import KaleyraVideoSDK

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
    }
}

extension MainQueueDispatchDecorator: UserRepository where T == UserRepository {

    func loadUsers(completion: @escaping (UserRepository.ResultContacts) -> Void) {
        decoratee.loadUsers { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: AccessTokenProvider where T: AccessTokenProvider {

    func provideAccessToken(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        decoratee.provideAccessToken(userId: userId) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
