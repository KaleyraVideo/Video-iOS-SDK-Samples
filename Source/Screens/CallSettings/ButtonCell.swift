// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ButtonCell: UICollectionViewCell {

    private lazy var button: UIButton = {
        let button = UIButton(button: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "minus.circle.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .small)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .init(rgb: 0x1B1B1B)
        button.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.deleteAction?(self)
        }), for: .touchUpInside)
        return button
    }()

    var deleteAction: ((UICollectionViewCell) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 46),
            button.leftAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leftAnchor),
            button.rightAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.rightAnchor)
        ])
    }

    func configure(for model: Button, shouldShowTitle: Bool) {
        button.updateFor(model, shouldShowTitle: shouldShowTitle)
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        if state.isEditing {
            startWobbling()
            contentView.addSubview(deleteButton)
            NSLayoutConstraint.activate([
                deleteButton.centerXAnchor.constraint(equalTo: button.leftAnchor, constant: 6),
                deleteButton.centerYAnchor.constraint(equalTo: button.topAnchor, constant: 1)
            ])
        } else {
            deleteButton.removeFromSuperview()
            stopWobbling()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        deleteAction = nil
    }
}

extension UICollectionViewCell {

    func startWobbling() {
        guard layer.animation(forKey: "wobble") == nil else { return }

        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0.0, -0.025, 0.0, 0.025, 0.0]
        animation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        animation.duration = 0.4
        animation.isAdditive = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animation, forKey: "wobble")
    }

    func stopWobbling() {
        guard layer.animation(forKey: "wobble") != nil else { return }

        layer.removeAnimation(forKey: "wobble")
    }
}

@available(iOS 15.0, *)
extension UIButton {

    convenience init(button: Button?) {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 18
        config.contentInsets = .init(top: 12, leading: 4, bottom: 12, trailing: 4)
        config.titleAlignment = .center
        config.titleLineBreakMode = .byTruncatingTail
        config.title = button?.title
        config.image = button?.icon ?? .init(systemName: "questionmark")
        config.titleTextAttributesTransformer = .init({ _ in
            .init([.font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12)),
                   .foregroundColor : button?.tintColor ?? UIColor(rgb: 0x1B1B1B)])
        })
        config.background.customView = ImageTrackingBackgroundView()
        self.init(configuration: config)
        tintColor = button?.tintColor
    }

    func updateFor(_ model: Button, shouldShowTitle: Bool) {
        configuration?.title = shouldShowTitle ? model.title : nil
        configuration?.image = model.icon
        configuration?.background.customView?.subviews.first?.backgroundColor = model.backgroundColor
        tintColor = model.tintColor
    }
}

private final class ImageTrackingBackgroundView: UIView {

    private lazy var decorationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 18
        view.backgroundColor = .init(rgb: 0xE2E2E2)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(decorationView)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        guard let button = newSuperview?.superview as? UIButton else { return }

        setupConstraintsToImageViewIfNeeded(button)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        guard let button = superview?.superview as? UIButton else { return }

        setupConstraintsToImageViewIfNeeded(button)
    }

    private func setupConstraintsToImageViewIfNeeded(_ button: UIButton) {
        guard let imageView = button.imageView else { return }
        guard imageView.isDescendant(of: button) else { return }
        guard imageView.image != nil else { return }
        guard isDescendant(of: button) else { return }
        guard imageView.constraints.isEmpty else { return }

        NSLayoutConstraint.activate([
            decorationView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            decorationView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            decorationView.widthAnchor.constraint(equalToConstant: 46),
            decorationView.heightAnchor.constraint(equalTo: decorationView.widthAnchor)
        ])
    }
}

@available(iOS 15.0, *)
private extension Button {

    var title: String {
        switch self {
            case .hangUp:
                "end"
            case .microphone:
                "mute"
            case .camera:
                "enable"
            case .flipCamera:
                "flip"
            case .cameraEffects:
                "effects"
            case .audioOutput:
                "audio output"
            case .fileShare:
                "fileshare"
            case .screenShare:
                "screenshare"
            case .chat:
                "chat"
            case .whiteboard:
                "board"
        }
    }

    var icon: UIImage? {
        let icon: UIImage? = switch self {
            case .hangUp:
                    .init(named: "end-call", in: .sdk, compatibleWith: nil)
            case .microphone:
                    .init(named: "mic-off", in: .sdk, compatibleWith: nil)
            case .camera:
                    .init(named: "camera-off", in: .sdk, compatibleWith: nil)
            case .flipCamera:
                    .init(named: "flipcam", in: .sdk, compatibleWith: nil)
            case .cameraEffects:
                    .init(named: "virtual-background", in: .sdk, compatibleWith: nil)
            case .audioOutput:
                    .init(named: "speaker-on", in: .sdk, compatibleWith: nil)
            case .fileShare:
                    .init(named: "file-share", in: .sdk, compatibleWith: nil)
            case .screenShare:
                    .init(named: "screen-share", in: .sdk, compatibleWith: nil)
            case .chat:
                    .init(named: "chat", in: .sdk, compatibleWith: nil)
            case .whiteboard:
                    .init(named: "whiteboard", in: .sdk, compatibleWith: nil)
        }
        return icon ?? .init(systemName: "questionmark")
    }

    var backgroundColor: UIColor {
        guard case Button.hangUp = self else {
            return .init(rgb: 0xE2E2E2)
        }
        return .init(rgb: 0xDC2138)
    }

    var tintColor: UIColor {
        guard case Button.hangUp = self else {
            return .init(rgb: 0x1B1B1B)
        }
        return .white
    }
}
