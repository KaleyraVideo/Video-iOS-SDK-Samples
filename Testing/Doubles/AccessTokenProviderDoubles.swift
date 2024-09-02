// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK
@testable import SDK_Sample

class AccessTokenProviderDummy: AccessTokenProvider {

    func provideAccessToken(userId: String, completion: @escaping (Result<String, Error>) -> Void) {}
}

class AccessTokenProviderSpy: AccessTokenProviderDummy {

    private(set) var provideAccessTokenInvocations = [(userId: String, completion: (Result<String, Error>) -> Void)]()

    override func provideAccessToken(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        provideAccessTokenInvocations.append((userId, completion))
    }
}

final class AccessTokenProviderMock: AccessTokenProviderSpy {

    func simulateFailure(_ error: Error) {
        provideAccessTokenInvocations.first?.1(.failure(error))
    }

    func simulateSuccess(token: String) {
        provideAccessTokenInvocations.first?.1(.success(token))
    }
}
