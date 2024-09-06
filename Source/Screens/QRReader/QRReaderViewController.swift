// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import AVFoundation
import UIKit

class QRReaderViewController: UIViewController, QRReaderCameraOutputDelegate {

    private let camera: QRReaderCamera

    var onDismiss: ((QRCode?) -> Void)?

    // MARK: - Subviews

    private lazy var cameraView: UIView = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        let view = UIView(frame: view.frame)
        view.layer.addSublayer(previewLayer)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var dismissButton: UIButton = {
        let button = RoundedButton()
        button.setTitle(Strings.QRReader.cancelAction, for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTouched(_:)), for: .touchUpInside)
        button.backgroundColor = Theme.Color.secondary
        button.setTitleColor(Theme.Color.commonWhiteColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(camera: QRReaderCamera = .init()) {
        self.camera = camera
        super.init(nibName: nil, bundle: nil)
        camera.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        view.addSubview(cameraView)
        view.addSubview(dismissButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cameraView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            dismissButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            dismissButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        camera.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        camera.stop()
    }

    // MARK: - Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - QRReaderCameraOutputDelegate

    func qrCode(read code: String) {
        guard let url = URL(string: code) else { return }

        do {
            let config = try QRCode.parse(from: url)

            onDismiss?(config)
            camera.stop()
        } catch {
            qrCode(failed: .invalidMetadata)
        }
    }

    func qrCode(failed error: QRReaderCameraError) {
        presentAlert(.error())
    }

    // MARK: - Actions

    @objc
    private func dismissButtonTouched(_ sender: UIButton) {
        onDismiss?(nil)
    }
}

private extension UIAlertController {

    static func error() -> UIAlertController {
        let alert = UIAlertController.alert(title: Strings.QRReader.Alert.title, message: Strings.QRReader.Alert.message)
        alert.addAction(.cancel(title: Strings.QRReader.Alert.okAction))
        return alert
    }
}
