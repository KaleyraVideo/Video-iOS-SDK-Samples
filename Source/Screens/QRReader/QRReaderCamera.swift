// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import AVFoundation

enum QRReaderCameraError: Error {
    case invalidMetadata
    case unableToStartCamera
}

protocol QRReaderCameraOutputDelegate: AnyObject {
    func qrCode(read code: String)
    func qrCode(failed error: QRReaderCameraError)
}

final class QRReaderCamera: NSObject {

    let session: AVCaptureSession
    private let metadataOutput: AVCaptureMetadataOutput

    weak var delegate: QRReaderCameraOutputDelegate?

    init(session: AVCaptureSession = AVCaptureSession(),
         metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()) {
        self.session = session
        self.metadataOutput = metadataOutput

        super.init()

        setupSession()
    }

    private func setupSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput),
              session.canAddOutput(metadataOutput) else {
            delegate?.qrCode(failed: .unableToStartCamera)
            return
        }

        session.addInput(videoInput)
        session.addOutput(metadataOutput)

        metadataOutput.metadataObjectTypes = [.qr]
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
    }

    func start() {
        guard !session.isRunning else { return }

        session.startRunning()
    }

    func stop() {
        guard session.isRunning else { return }

        session.stopRunning()
    }
}

extension QRReaderCamera: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue,
                object.type == .qr else {
                delegate?.qrCode(failed: .invalidMetadata)
                return
        }

        delegate?.qrCode(read: code)
    }
}
