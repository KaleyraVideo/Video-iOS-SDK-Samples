// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ButtonCell: UICollectionViewCell {

    private lazy var button: UIButton = {
        let button = UIButton(button: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()

    private lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Icons.removeButton
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .small)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Theme.Color.defaultButtonTint
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

@available(iOS 15.0, *)
extension UIButton {

    convenience init(button: Button?) {
        var config = UIButton.Configuration.bottomSheetButton()
        config.title = button?.title
        config.image = button?.icon ?? Icons.questionMark
        let tintColor = button?.tintColor
        config.titleTextAttributesTransformer = .init({ [tintColor] _ in
            .init([.font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12)),
                   .foregroundColor : tintColor ?? Theme.Color.defaultButtonTint])
        })
        let backgroundView = ImageTrackingButtonBackgroundView()
        backgroundView.backgroundColor = button?.backgroundColor
        config.background.customView = backgroundView
        self.init(configuration: config)
        self.tintColor = tintColor
    }

    func updateFor(_ model: Button, shouldShowTitle: Bool) {
        configuration?.title = shouldShowTitle ? model.title : nil
        configuration?.image = model.icon
        configuration?.background.customView?.backgroundColor = model.backgroundColor
        tintColor = model.tintColor
    }
}

@available(iOS 15.0, *)
private extension Button {

    var title: String {
        switch self {
            case .hangUp: "end"
            case .microphone: "mute"
            case .camera: "enable"
            case .flipCamera: "flip"
            case .cameraEffects: "effects"
            case .audioOutput: "audio output"
            case .fileShare: "fileshare"
            case .screenShare: "screenshare"
            case .chat: "chat"
            case .whiteboard: "board"
            case .addCustom: "new"
        }
    }

    var icon: UIImage? {
        let icon: UIImage? = switch self {
            case .hangUp: Icons.end
            case .microphone: Icons.micOff
            case .camera: Icons.cameraOff
            case .flipCamera: Icons.flipCamera
            case .cameraEffects: Icons.cameraEffects
            case .audioOutput: Icons.speakerOn
            case .fileShare: Icons.fileShare
            case .screenShare: Icons.screenShare
            case .chat: Icons.chat
            case .whiteboard: Icons.whiteboard
            case .addCustom: Icons.addButton
        }
        return icon ?? Icons.questionMark
    }

    var backgroundColor: UIColor {
        guard case Button.hangUp = self else {
            return Theme.Color.defaultButtonBackground
        }
        return .init(rgb: 0xDC2138)
    }

    var tintColor: UIColor {
        guard case Button.hangUp = self else {
            return Theme.Color.defaultButtonTint
        }
        return .white
    }
}
