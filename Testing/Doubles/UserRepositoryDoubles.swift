// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

final class UserRepositoryDummy: UserRepository {
    func loadUsers(completion: @escaping (ResultContacts) -> Void) {}
}

final class UserRepositoryMock: UserRepository {

    enum MockError: Error {
        case loadUsersNotCalled
        case dummyError
    }

    private var completion: ((Result<[String], Error>) -> Void)?

    func loadUsers(completion: @escaping (Result<[String], Error>) -> Void) {
        self.completion = completion
    }

    func simulateLoadUsersSuccess(users: [String]) throws {
        guard let completion = self.completion else { throw MockError.loadUsersNotCalled }
        completion(.success(users))
    }

    func simulateLoadUsersFailure(error: Error) throws {
        guard let completion = self.completion else { throw MockError.loadUsersNotCalled }
        completion(.failure(error))
    }
}
