// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
@testable import SDK_Sample

@available(iOS 15.0, *)
final class ThemeCoordinatorTests: UnitTestCase {

    private var nav: TestableNavigationController!
    private var sut: ThemeCoordinator!

    override func setUp() {
        super.setUp()

        nav = .init()
        sut = .init(navigationController: nav, services: ServicesFactoryStub())
    }

    override func tearDown() {
        sut = nil
        nav = nil

        super.tearDown()
    }

    func testStartShouldPushThemeViewControllerOntoNavigationStack() {
        sut.start()

        assertThat(nav.viewControllers, hasCount(1))
        assertThat(nav.viewControllers.first, presentAnd(instanceOf(ThemeViewController.self)))
    }
}
