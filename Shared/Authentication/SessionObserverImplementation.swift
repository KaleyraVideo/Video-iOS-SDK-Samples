//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer

// You can observe for authentication event implementing a SessionObserver protocol conform object and
// passing it to the Session object during the initialization process
class SessionObserverImplementation: SessionObserver {

    func sessionWillAuthenticate(_ session: Session) {
        debugPrint("session \(session) will authenticate")
    }

    func sessionDidAuthenticate(_ session: Session) {
        debugPrint("session \(session) did authenticate")
    }

    func sessionWillRefresh(_ session: Session) {
        debugPrint("session \(session) will refresh")
    }

    func sessionDidRefresh(_ session: Session) {
        debugPrint("session \(session) did refresh")
    }

    func session(_ session: Session, didFailWith error: Error) {
        debugPrint("session \(session) didFailWith \(error)")
    }
}
