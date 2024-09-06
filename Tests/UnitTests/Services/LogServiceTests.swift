// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
import KaleyraVideoSDK
@testable import SDK_Sample

final class LogServiceTests: UnitTestCase {

    // MARK: - Log Files Present

    func testAreLogFilesPresentShouldAskForCacheDirectoryToFileManager() {
        let filemanager = makeFileManagerSpy()
        let sut = makeSUT(fileManager: filemanager)

        filemanager.resetInvocations()
        _ = sut.areLogFilesPresent

        assertThat(filemanager.urlsForDirectoryInvocations, hasCount(1))
        assertThat(filemanager.urlsForDirectoryInvocations.first?.directory, presentAnd(equalTo(.cachesDirectory)))
        assertThat(filemanager.urlsForDirectoryInvocations.first?.domainMask, presentAnd(equalTo(.userDomainMask)))
    }

    func testAreLogFilesPresentShouldAskForFileManagerContentsOfLogFilesDir() {
        let cacheDir = anyURL()
        let expectedLogDir = cacheDir.appendingPathComponent("Logs")
        let filemanager = makeFileManagerSpy()
        let sut = makeSUT(fileManager: filemanager)

        filemanager.mockUrlsInDirectory([cacheDir])
        _ = sut.areLogFilesPresent

        assertThat(filemanager.contentsOfDirectoryInvocations, hasCount(1))
        assertThat(filemanager.contentsOfDirectoryInvocations.first?.url, presentAnd(equalTo(expectedLogDir)))
        assertThat(filemanager.contentsOfDirectoryInvocations.first?.keys, nilValue())
        assertThat(filemanager.contentsOfDirectoryInvocations.first?.mask, presentAnd(equalTo([])))
    }

    func testAreLogFilesPresentShouldReturnTrueIfThereIsSomethingInLogDirectoryOtherwhiseFalse() {
        let filemanager = makeFileManagerSpy()
        let sut = makeSUT(fileManager: filemanager)

        filemanager.mockUrlsInDirectory([anyURL()])
        let logsMissing = sut.areLogFilesPresent
        filemanager.mockContentsOfDirectory([anyURL()])
        let logsPresent = sut.areLogFilesPresent

        assertThat(logsMissing, isFalse())
        assertThat(logsPresent, isTrue())
    }

    func testLogFileList() {
        let logDirContent = [anyURL(), anyURL(), anyURL()]
        let filemanager = makeFileManagerMock()
        let sut = makeSUT(fileManager: filemanager)

        filemanager.mockUrlsInDirectory([anyURL()])
        filemanager.mockContentsOfDirectory(logDirContent)
        let logFileList = sut.logFileList

        assertThat(logFileList, equalTo(logDirContent))
    }

    // MARK: - Setup

    func testSetupShouldAddShortcutsToShortcutsHolderIfLogsArePresent() {
        let holder = makeShortcutItemsHolderMock()
        let sut = makeSUT(fileManager: makeFileManagerWithLogFilesPresent(),
                          holder: holder)

        assertThat(holder.shortcutItems, presentAnd(hasCount(1)))
        assertThat(holder.shortcutItems?.first?.type, presentAnd(equalTo("share_logs")))
        assertThat(holder.shortcutItems?.first?.localizedTitle, presentAnd(equalToLocalizedString("logs.shortcut.title", bundle: .main)))
        assertThat(holder.shortcutItems?.first?.localizedSubtitle, nilValue())
        assertThat(holder.shortcutItems?.first?.icon, presentAnd(equalTo(.init(systemImageName: "ladybug"))))
    }

    func testShouldRemoveShortcutItemsIfNoLogsArePresent() {
        let holder = makeShortcutItemsHolderMock()
        holder.shortcutItems = makeShortcutItems()
        let sut = makeSUT(holder: holder)

        assertThat(holder.shortcutItems, nilValue())
    }

    // MARK: - Start/Stop Logging

    func testStartLoggingShouldEnableLogsOnBandyerSDK() {
        let sut = makeSUT()

        sut.startLogging()

        assertThat(BandyerSDKProtocolMock.logLevel, equalTo(.all))
        assertThat(BandyerSDKProtocolMock.loggers, equalTo([.console, .file]))
    }

    func testStartLoggingShouldAddShortcutsToShortcutsHolder() {
        let holder = makeShortcutItemsHolderMock()
        let sut = makeSUT(holder: holder)

        sut.startLogging()

        assertThat(holder.shortcutItems, presentAnd(hasCount(1)))
    }

    func testStopLoggingShouldDisableLogsOnBandyerSDK() {
        let sut = makeSUT()

        sut.startLogging()
        sut.stopLogging()

        assertThat(BandyerSDKProtocolMock.logLevel, equalTo(.off))
        assertThat(BandyerSDKProtocolMock.loggers, equalTo([]))
    }

    func testStopLoggingShouldRefreshShortcutsItems() {
        let holder = makeShortcutItemsHolderMock()
        let sut = makeSUT(holder: holder)

        sut.startLogging()
        sut.stopLogging()

        assertThat(holder.shortcutItems, nilValue())
    }

    // MARK: - Helpers

    private func makeSUT(fileManager: FileManagerProtocol = makeFileManagerMock(),
                         holder: ShortcutItemsHolder = makeShortcutItemsHolderMock(),
                         bandyerSDKType: SDK.Type = BandyerSDKProtocolMock.self) -> LogService {
        .init(fileManager: fileManager, holder: holder, bandyerSDKType: bandyerSDKType)
    }

    private func makeFileManagerSpy() -> FileManagerSpy {
        .init()
    }

    private func makeFileManagerWithLogFilesPresent() -> FileManagerMock {
        let filemanager = makeFileManagerMock()
        filemanager.mockUrlsInDirectory([anyURL()])
        filemanager.mockContentsOfDirectory([anyURL()])
        return filemanager
    }

    private func makeFileManagerMock() -> FileManagerMock {
        LogServiceTests.makeFileManagerMock()
    }

    private static func makeFileManagerMock() -> FileManagerMock {
        .init()
    }

    private func makeShortcutItemsHolderMock() -> ShortcutItemsHolderMock {
        LogServiceTests.makeShortcutItemsHolderMock()
    }

    private static func makeShortcutItemsHolderMock() -> ShortcutItemsHolderMock {
        .init()
    }

    private func makeShortcutItems() -> [UIApplicationShortcutItem] {
        [.init(type: "", localizedTitle: "")]
    }

    // MARK: - Doubles

    private class FileManagerSpy: FileManagerMock {

        private(set) var urlsForDirectoryInvocations = [(directory: FileManager.SearchPathDirectory, domainMask: FileManager.SearchPathDomainMask)]()
        private(set) var contentsOfDirectoryInvocations = [(url: URL, keys: [URLResourceKey]?, mask: FileManager.DirectoryEnumerationOptions)]()

        override func urls(for directory: FileManager.SearchPathDirectory,
                  in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
            urlsForDirectoryInvocations.append((directory: directory, domainMask: domainMask))

            return super.urls(for: directory, in: domainMask)
        }

        override func contentsOfDirectory(at url: URL,
                                 includingPropertiesForKeys keys: [URLResourceKey]?,
                                 options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
            contentsOfDirectoryInvocations.append((url: url, keys: keys, mask: mask))

            return try super.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: mask)
        }

        func resetInvocations() {
            urlsForDirectoryInvocations.removeAll()
            contentsOfDirectoryInvocations.removeAll()
        }
    }

    private class FileManagerMock: FileManagerProtocol {

        private var urlsInDirectoryMock = [URL]()
        private var contentsOfDirectoryMock = [URL]()

        func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
            urlsInDirectoryMock
        }

        func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
            contentsOfDirectoryMock
        }

        func mockUrlsInDirectory(_ urls: [URL]) {
            urlsInDirectoryMock = urls
        }

        func mockContentsOfDirectory(_ urls: [URL]) {
            contentsOfDirectoryMock = urls
        }
    }

    private class ShortcutItemsHolderMock: ShortcutItemsHolder {

        var shortcutItems: [UIApplicationShortcutItem]?
    }

    private class BandyerSDKProtocolMock: SDK {

        static var logLevel: KaleyraVideoSDK.LogLevel = .all
        static var loggers: KaleyraVideoSDK.Loggers = []
    }
}
