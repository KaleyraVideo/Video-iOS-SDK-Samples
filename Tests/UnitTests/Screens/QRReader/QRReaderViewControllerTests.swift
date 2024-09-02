// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import AVFoundation
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class QRReaderViewControllerTests: UnitTestCase, QRCodeFixtureFactory {

    func testShouldCallDismissActionWhenDismissButtonIsTouched() throws {
        let actionSpy = makeActionSpy()
        let sut = makeSUT()
        sut.onDismiss = actionSpy.callAsFunction

        sut.dismissButton?.sendActions(for: .touchUpInside)

        assertThat(actionSpy.invocations, hasCount(1))
    }

    func testMainViewContainsAPreviewViewLayerOfTheCaptureCameraSession() throws {
        let sut = makeSUT()

        let view = try unwrap(sut.cameraView)
        let layer = view.layer.sublayers?.filter({ $0 is AVCaptureVideoPreviewLayer}).first

        assertThat(layer, present())
    }

    func testSupportedDeviceOrientationIsPortrait() {
        let sut = makeSUT()

        assertThat(sut.supportedInterfaceOrientations, equalTo([.portrait]))
    }

    func testCallFailedDelegateWhenTheReadCodeIsNotAnUrl() {
        let sut = makeSUT()

        sut.qrCode(read: "malformed")

        assertThat(sut.qrErrorFailedCalls, hasCount(1))
    }

    func testCallFailedDelegateWhenThereIsAMalformedUrlInsideQRCode() {
        let sut = makeSUT()

        sut.qrCode(read: makeMalformedStringConfiguration().absoluteString)

        assertThat(sut.qrErrorFailedCalls, hasCount(1))
    }

    func testCallOnDismissWithCorrectConfigurationWhenReadAValidUrlFromQRCode() {
        let actionSpy = makeActionSpy()
        let sut = makeSUT()
        sut.onDismiss = actionSpy.callAsFunction(_:)

        sut.qrCode(read: makeValidConfiguration(environment: "sandbox", region: "eu", callType: "AUDIO_ONLY").absoluteString)

        assertThat(actionSpy.invocations, hasCount(1))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> QRReaderViewControllerSpy {
        let camera = QRReaderCamera()
        let sut = QRReaderViewControllerSpy(camera: camera)

        let _ = sut.view

        assertDeallocatedOnTeardown(sut)
        assertDeallocatedOnTeardown(camera)

        return sut
    }

    private func makeActionSpy() -> CompletionSpy<QRCode?> {
        .init()
    }
}

private extension QRReaderViewController {

    var cameraView: UIView? {
        view.firstDescendant()
    }

    var dismissButton: UIButton? {
        view.firstDescendant()
    }
}

private class QRReaderViewControllerSpy: QRReaderViewController {

    private(set) var qrErrorFailedCalls = [Error]()

    override func qrCode(failed error: QRReaderCameraError) {
        super.qrCode(failed: error)
        qrErrorFailedCalls.append(error)
    }
}

