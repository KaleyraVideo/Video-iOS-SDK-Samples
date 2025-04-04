// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit
import Intents
import KaleyraVideoSDK

@objc(SceneDelegate)
final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    private lazy var services: ServicesFactory = {
        DefaultServicesFactory()
    }()

    fileprivate lazy var coordinator: RootCoordinator = {
        .init(services: services)
    }()

    var window: UIWindow?

    private lazy var pendingActivities = [NSUserActivity]()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        window?.tintColor = Theme.Color.primary
        window?.rootViewController = coordinator.controller
        window?.makeKeyAndVisible()
        coordinator.start()

        connectionOptions.userActivities.forEach({ pendingActivities.append($0) })

        guard let shortcutItem = connectionOptions.shortcutItem else { return }

        windowScene(scene, performActionFor: shortcutItem, completionHandler: { _ in })
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard !pendingActivities.isEmpty else { return }

        pendingActivities.forEach {
            self.scene(scene, continue: $0)
        }
        pendingActivities.removeAll()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            guard let url = userActivity.webpageURL else { return }
            guard scene.activationState == .foregroundActive else {
                pendingActivities.append(userActivity)
                return
            }
            guard coordinator.handle(event: .startCall(url: url), direction: .toChildren) else { return }

            debugPrint("Could not handle url \(url)")
        } else if let siriIntent = userActivity.interaction?.intent {
            guard coordinator.handle(event: .siri(intent: siriIntent), direction: .toChildren) else { return }
            debugPrint("Could not handle siri intent")
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard shortcutItem.isShareLogs else {
            completionHandler(false)
            return
        }
        coordinator.shareLogs()
        completionHandler(true)
    }

    // MARK: - Push notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard !coordinator.handle(event: .pushToken(token: deviceToken.pushToken), direction: .toChildren) else { return }
        print("An error occurred while handling push device token")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        defer { completionHandler(.newData) }

        guard application.applicationState != .active else {
            return
        }

        handleUserChatNotification(userInfo: userInfo)
    }

    private func handleUserChatNotification(userInfo: [AnyHashable : Any]) {
        guard let payload = userInfo["payload"] as? [String: AnyObject],
              payload["event"] as? String == "on_message_sent",
              let payloadData = payload["data"] as? [String: AnyObject],
              let channelID = payloadData["channel_id"] as? String else { return }
        guard !coordinator.handle(event: .chatNotification(chatId: channelID), direction: .toChildren) else { return }
        print("Error on handling chat notification")
    }
}

private extension UIApplicationShortcutItem {

    var isShareLogs: Bool {
        type == LogServiceConstants.shareLogsItemType
    }
}

extension UIWindow {

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        guard motion == .motionShake, let windowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }

        _ = delegate.coordinator.handle(event: .toggleFloatingMessage, direction: .toChildren)
    }
}
