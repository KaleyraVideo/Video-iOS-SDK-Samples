//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer

class SessionFactory {

    static func makeSession(for userID: String) -> Session {
        // Here is how you compose a session object before connecting it
        Session(userId: userID,
                tokenProvider: AccessTokenProviderMock(),
                observer: SessionObserverImplementation())
    }
}
