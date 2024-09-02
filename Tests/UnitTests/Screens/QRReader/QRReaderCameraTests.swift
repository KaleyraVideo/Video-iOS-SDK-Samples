// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import XCTest
import AVFoundation
import SwiftHamcrest
import KaleyraTestKit
@testable import SDK_Sample

final class QRReaderCameraTests: UnitTestCase {

    let delegate = CameraOutputSpy()
    let camera = QRReaderCamera()

    func testNotifiesDelegateWhenQRCodeIsDetected() {

        camera.delegate = delegate

        camera.metadataOutput(
            AVCaptureMetadataOutput(),
            didOutput: [
                FakeMachineReadableCodeObject.createFake(withCode: "QR code value", type: .qr)
            ],
            from: AVCaptureConnection(
                inputPorts: [],
                output: FakeAVCaptureOutputCodeObject.createFake()
          )
        )

        assertThat(delegate.invocations, equalTo([.detected("QR code value")]))
    }

    func testNotifiesDelegateWhenAnErrorOccursWhileDetectingQRCode() {
        camera.delegate = delegate

        camera.metadataOutput(
            AVCaptureMetadataOutput(),
            didOutput: [
                FakeMachineReadableCodeObject.createFake(withCode: "interleaved2of5 value", type: .interleaved2of5)
            ],
            from: AVCaptureConnection(
                inputPorts: [],
                output: FakeAVCaptureOutputCodeObject.createFake()
          )
        )

        assertThat(delegate.invocations, equalTo([.error(QRReaderCameraError.invalidMetadata)]))
    }
}

final class CameraOutputSpy: QRReaderCameraOutputDelegate {

    private(set) var invocations = [Invocation]()

    enum Invocation: Equatable, CustomDebugStringConvertible {
        case detected(String)
        case error(Error)

        var debugDescription: String {
            switch self {
                case .detected(let code):
                    return "detected(\(code))"
                case .error(let error):
                    return "error(\(error))"
            }
        }

        static func == (lhs: CameraOutputSpy.Invocation, rhs: CameraOutputSpy.Invocation) -> Bool {
            switch (lhs, rhs) {
                case (detected(let lhsCode), detected(let rhsCode)):
                    return lhsCode == rhsCode
                case (error(let lhsError), error(let rhsError)):
                    return (lhsError as NSError) == (rhsError as NSError)
                case (_, _):
                    return false
            }
        }
    }

    func qrCode(read code: String) {
        invocations.append(.detected(code))
    }

    func qrCode(failed error: QRReaderCameraError) {
        invocations.append(.error(error))
    }
}
