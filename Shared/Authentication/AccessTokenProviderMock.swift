//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer

class AccessTokenProviderMock: AccessTokenProvider {

    // The Kaleyra Video platform now uses a strong authentication mechanism based on JWT tokens while authenticating
    // its clients. You are required to provide an object conforming to the AccessTokenProvider protocol to the Session
    // object before connecting the SDK. The Kaleyra Video SDK will call the provideAccessToken(userId:completion:) method
    // every time it needs an access token.
    func provideAccessToken(userId: String, completion: @escaping (Result<String, Error>) -> Void) {

        // Here you are supposed to request a new access token to your backend system
        let newAccessToken = "FRESH NEW TOKEN"

        // Once you obtained back an Access Token from your backend you should call the completion block passing it as argument.
        // If an error occurred in your token retrieve process call the completion block with Result value indicating the failure occurred.
        completion(.success(newAccessToken))
    }
}
