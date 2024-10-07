// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK

protocol ServicesFactory {

    func makeSettingsRepository() -> SettingsRepository
    func makeAddressBook(config: Config) -> AddressBook
    func makeAccessTokenProvider(config: Config) -> AccessTokenProvider
    func makePushTokenRepository(config: Config) -> PushTokenRepository

    @available(iOS 15.0, *)
    func makeVoIPManager(config: Config) -> VoIPNotificationsManager
    func makePushManager(config: Config) -> PushManager

    @available(iOS 15.0, *)
    func makeSDK() -> KaleyraVideo
    func makeLogService() -> LogServiceProtocol
}

final class DefaultServicesFactory: ServicesFactory {

    private lazy var defaultsStore: UserDefaultsStore = .init()
    private lazy var logService = LogService()

    func makeSettingsRepository() -> SettingsRepository {
        defaultsStore
    }

    func makeAddressBook(config: Config) -> AddressBook {
        AddressBook(repository: makeUserRepository(config: config).mainDecorator())
    }

    private func makeUserRepository(config: Config) -> UserRepository {
        RestUserRepository(client: makeAuthenticatedHTTPClient(config: config), config: config)
    }

    func makeAccessTokenProvider(config: Config) -> AccessTokenProvider {
        let tokenLoader = RestAccessTokenProvider(client: makeAuthenticatedHTTPClient(config: config), config: config)
        return MainQueueDispatchDecorator<RestAccessTokenProvider>(decoratee: tokenLoader)
    }

    private func makeAuthenticatedHTTPClient(config: Config) -> HTTPClient {
        AuthenticatedHTTPClient(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)), token: config.keys.apiKey.description)
    }

    func makePushTokenRepository(config: Config) -> PushTokenRepository {
        RestPushTokenRepository(config: config)
    }

    @available(iOS 15.0, *)
    func makeVoIPManager(config: Config) -> VoIPNotificationsManager {
        .init(config: config, registry: makePushTokenRepository(config: config), sdk: makeSDK())
    }

    func makePushManager(config: Config) -> PushManager {
        .init(registry: makePushTokenRepository(config: config), repository: makeSettingsRepository())
    }

    @available(iOS 15.0, *)
    func makeSDK() -> KaleyraVideo {
        .instance
    }

    func makeLogService() -> LogServiceProtocol {
        logService
    }
}
