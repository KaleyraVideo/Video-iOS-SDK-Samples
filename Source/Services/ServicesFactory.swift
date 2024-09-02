// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

protocol ServicesFactory {

    func makeUserDefaultsStore() -> UserDefaultsStore
    func makeContactsStore(config: Config) -> ContactsStore
    func makeUserRepository(config: Config) -> UserRepository
    func makeTokenLoader(config: Config) -> AccessTokenProvider
    func makePushTokenRepository(config: Config) -> PushTokenRepository
    func makeVoIPManager(config: Config) -> VoIPNotificationsManager
    func makePushManager(config: Config) -> PushManager
    func makeSDK() -> KaleyraVideo
    func makeLogService() -> LogServiceProtocol

#if SAMPLE_CUSTOMIZABLE_THEME
    func makeThemeStorage() -> ThemeStorage
#endif
}

final class DefaultServicesFactory: ServicesFactory {

    private lazy var defaultsStore: UserDefaultsStore = .init()
    private lazy var logService = LogService()
    private var contactsStore: ContactsStore?

    func makeUserDefaultsStore() -> UserDefaultsStore {
        defaultsStore
    }

    func makeUserRepository(config: Config) -> UserRepository {
        RestUserRepository(client: makeAuthenticatedHTTPClient(config: config), config: config)
    }

    func makeContactsStore(config: Config) -> ContactsStore {
        guard let contactsStore else {
            let store = ContactsStore(repository: makeUserRepository(config: config).mainDecorator())
            contactsStore = store
            return store
        }
        return contactsStore
    }

    func makeTokenLoader(config: Config) -> AccessTokenProvider {
        let tokenLoader = RestAccessTokenProvider(client: makeAuthenticatedHTTPClient(config: config), config: config)
        return MainQueueDispatchDecorator<RestAccessTokenProvider>(decoratee: tokenLoader)
    }

    private func makeAuthenticatedHTTPClient(config: Config) -> HTTPClient {
        AuthenticatedHTTPClient(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)), token: config.keys.apiKey.description)
    }

    func makePushTokenRepository(config: Config) -> PushTokenRepository {
        RestPushTokenRepository(config: config)
    }

    func makeVoIPManager(config: Config) -> VoIPNotificationsManager {
        VoIPNotificationsManager(config: config, registry: makePushTokenRepository(config: config), sdk: makeSDK())
    }

    func makePushManager(config: Config) -> PushManager {
        PushManager(registry: makePushTokenRepository(config: config), store: makeUserDefaultsStore())
    }

    func makeSDK() -> KaleyraVideo {
        .instance
    }

    func makeLogService() -> LogServiceProtocol {
        logService
    }

#if SAMPLE_CUSTOMIZABLE_THEME

    private lazy var themeStorage: ThemeStorage = UserDefaultsThemeStorage()

    func makeThemeStorage() -> ThemeStorage {
        themeStorage
    }

#endif
}
