// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
@testable import SDK_Sample

final class LogServiceSpy: LogServiceProtocol {

    private var _logFileList: [URL] = []
    private(set) var startLoggingInvocations: [Void] = []
    private(set) var stopLoggingInvocations: [Void] = []

    var areLogFilesPresent: Bool {
        !logFileList.isEmpty
    }

    var logFileList: [URL] {
        _logFileList
    }

    func startLogging() {
        startLoggingInvocations.append()
    }

    func stopLogging() {
        stopLoggingInvocations.append()
    }

    func mockLogFileListe(_ list: [URL]) {
        _logFileList = list
    }
}
