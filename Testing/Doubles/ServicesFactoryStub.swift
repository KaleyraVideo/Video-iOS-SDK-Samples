// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK
@testable import SDK_Sample

class ServicesFactoryStub: ServicesFactory {

    var userDefaultsStore: UserDefaultsStore = .init()
    var userRepository: UserRepository = UserRepositoryDummy()
    var tokenProvider: AccessTokenProvider = AccessTokenProviderDummy()
    var store: ContactsStore?

    func makeUserDefaultsStore() -> UserDefaultsStore {
        userDefaultsStore
    }

    func makeUserRepository(config: SDK_Sample.Config) -> UserRepository {
        userRepository
    }

    func makeTokenLoader(config: SDK_Sample.Config) -> AccessTokenProvider {
        tokenProvider
    }

    func makeContactsStore(config: SDK_Sample.Config) -> ContactsStore {
        store ?? .init(repository: userRepository)
    }

    func makeSDK() -> KaleyraVideoSDK.KaleyraVideo {
        .instance
    }

    func makePushTokenRepository(config: SDK_Sample.Config) -> PushTokenRepository {
        RestPushTokenRepository(config: config)
    }

    func makeVoIPManager(config: SDK_Sample.Config) -> VoIPNotificationsManager {
        .init(config: config, registry: makePushTokenRepository(config: config) , sdk: .instance)
    }

    func makePushManager(config: SDK_Sample.Config) -> PushManager {
        .init(registry: makePushTokenRepository(config: config), store: .init())
    }

    func makeLogService() -> LogServiceProtocol {
        fatalError()
    }
}
