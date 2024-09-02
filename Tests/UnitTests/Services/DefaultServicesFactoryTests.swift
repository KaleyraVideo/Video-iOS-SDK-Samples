// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class DefaultServicesFactoryTests: UnitTestCase {

    func testMakeLogService() {
        let sut = makeSUT()

        let logService = sut.makeLogService()

        assertThat(logService, instanceOf(LogService.self))
    }

    func testShouldReturnAlwaysTheSameLogServiceInstance() throws {
        let sut = makeSUT()

        let logService = try unwrap(sut.makeLogService() as? LogService)
        let otherLogService = try unwrap(sut.makeLogService() as? LogService)

        assertThat(logService, sameInstance(otherLogService))
    }

    // MARK: - Helpers

    private func makeSUT() -> DefaultServicesFactory {
        .init()
    }
}
