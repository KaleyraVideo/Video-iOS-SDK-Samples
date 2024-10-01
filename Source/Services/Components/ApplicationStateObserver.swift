// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import Combine

final class ApplicationStateObserver {

    @Published
    private(set) var state: UIApplication.State

    var isCurrentAppStateBackground: Bool {
        state == .background
    }

    convenience init(center: NotificationCenter = .default, application: UIApplication = .shared) {
        let mapper: (Notification) -> UIApplication.State = { _ in application.applicationState }
        let activePublisher = center.publisher(for: UIApplication.didBecomeActiveNotification).map(mapper)
        let backgroundPublisher = center.publisher(for: UIApplication.didEnterBackgroundNotification).map(mapper)
        let publisher = Deferred {
            Future { promise in
                guard !Thread.isMainThread else {
                    promise(.success(application.applicationState))
                    return
                }
                DispatchQueue.main.async {
                    promise(.success(application.applicationState))
                }
            }
        }.merge(with: backgroundPublisher).merge(with: activePublisher)
        self.init(initialState: .background, publisher: publisher)
    }

    init<P: Publisher>(initialState: UIApplication.State, publisher: P) where P.Output == UIApplication.State, P.Failure == Never {
        state = initialState
        guard #available(iOS 14.0, *) else { return }
        publisher.assign(to: &$state)
    }
}
