// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import CallKit
import KaleyraVideoSDK

final class DelayedUserDetailsProvider: UserDetailsProvider {

    let provider: UserDetailsProvider

    init(provider: UserDetailsProvider) {
        self.provider = provider
    }

    func provideDetails(_ aliases: [String], completion: @escaping (Result<[KaleyraVideoSDK.UserDetails], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.provider.provideDetails(aliases, completion: completion)
        }
    }
}
