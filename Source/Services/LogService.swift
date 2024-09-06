// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import KaleyraVideoSDK
import UIKit

enum LogServiceConstants {

    static var shareLogsItemType: String = "share_logs"
}

protocol LogServiceProtocol: AnyObject {

    var areLogFilesPresent: Bool { get }
    var logFileList: [URL] { get }

    func startLogging()
    func stopLogging()
}

final class LogService: LogServiceProtocol {

    // MARK: - Properties

    private let fileManager: FileManagerProtocol
    private let holder: ShortcutItemsHolder
    private let sdk: SDK.Type

    var areLogFilesPresent: Bool {
        !logFileList.isEmpty
    }

    private var logDirUrl: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Logs")
    }

    var logFileList: [URL] {
        guard let logDirUrl = logDirUrl,
                let contents = try? fileManager.contentsOfDirectory(at: logDirUrl,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: []) else {
            return []
        }

        return contents
    }

    // MARK: - Init

    init(fileManager: FileManagerProtocol = FileManager.default,
         holder: ShortcutItemsHolder = UIApplication.shared,
         bandyerSDKType: SDK.Type = KaleyraVideo.self) {
        self.fileManager = fileManager
        self.holder = holder
        self.sdk = bandyerSDKType

        setup()
    }

    // MARK: - Setup

    private func setup() {
        refreshShortcutItems()
    }

    // MARK: - Shortcut Items

    private func refreshShortcutItems() {
        guard areLogFilesPresent else {
            removeShortcutItems()
            return
        }
        addShortcutItems()
    }

    private func addShortcutItems() {
        holder.shortcutItems = makeShortcutItems()
    }

    private func removeShortcutItems() {
        holder.shortcutItems = nil
    }

    private func makeShortcutItems() -> [UIApplicationShortcutItem] {
        [.init(type: LogServiceConstants.shareLogsItemType,
               localizedTitle: Strings.Logs.Shortcut.title,
               localizedSubtitle: nil,
               icon: Icons.logShortcut)]
    }

    // MARK: - Logging

    func startLogging() {
        sdk.logLevel = .all
        sdk.loggers = [.file, .console]

        addShortcutItems()
    }

    func stopLogging() {
        KaleyraVideo.loggers = []
        sdk.logLevel = .off
        sdk.loggers = []

        refreshShortcutItems()
    }
}
