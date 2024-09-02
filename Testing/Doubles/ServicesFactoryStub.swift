// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK
@testable import SDK_Sample

class ServicesFactoryStub: ServicesFactory {

    private let userDefaultsStore: UserDefaultsStore
    private let userLoader: UserRepository
    private let tokenProvider: AccessTokenProvider

    init(userDefaultsStore: UserDefaultsStore = .init(), userLoader: UserRepository = UserRepositoryDummy(), tokenProvider: AccessTokenProvider = AccessTokenProviderDummy()) {
        self.userDefaultsStore = userDefaultsStore
        self.userLoader = userLoader
        self.tokenProvider = tokenProvider
    }

    func makeUserDefaultsStore() -> UserDefaultsStore {
        userDefaultsStore
    }

    func makeUserRepository(config: SDK_Sample.Config) -> UserRepository {
        userLoader
    }

    func makeTokenLoader(config: SDK_Sample.Config) -> AccessTokenProvider {
        tokenProvider
    }

    func makeContactsStore(config: SDK_Sample.Config) -> SDK_Sample.ContactsStore {
        .init(repository: UserRepositoryMock())
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
