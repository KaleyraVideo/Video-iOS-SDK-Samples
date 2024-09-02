// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct PushTokenRegistrationRequest {

    let userID: String
    let token: String
    let isVoip: Bool
}

struct PushTokenDeregistrationRequest {

    let userID: String
    let token: String
}

protocol PushTokenRepository {

    func registerToken(request: PushTokenRegistrationRequest, completion: @escaping (Result<Void, Error>) -> Void)
    func deregisterToken(request: PushTokenDeregistrationRequest, completion: @escaping (Result<Void, Error>) -> Void)
}
