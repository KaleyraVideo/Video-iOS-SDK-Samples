// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ButtonCell: UICollectionViewCell {

    enum SecondaryAction {
        case edit
        case delete

        var image: UIImage {
            switch self {
                case .edit: Icons.pencil
                case .delete: Icons.trash
            }
        }

        var backgroundColor: UIColor {
            switch self {
                case .edit: .systemBlue
                case .delete: .init(rgb: 0xDC2138)
            }
        }
    }

    private lazy var button: UIButton = {
        let button = UIButton(button: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()

    var secondaryAction: SecondaryAction? = nil {
        didSet {
            guard secondaryAction != oldValue else { return }

            if secondaryAction != nil, secondaryButton.superview == nil {
                contentView.addSubview(secondaryButton)
                NSLayoutConstraint.activate([
                    secondaryButton.centerXAnchor.constraint(equalTo: button.leftAnchor, constant: 11),
                    secondaryButton.centerYAnchor.constraint(equalTo: button.topAnchor, constant: 6),
                    secondaryButton.widthAnchor.constraint(lessThanOrEqualToConstant: 34),
                    secondaryButton.heightAnchor.constraint(lessThanOrEqualToConstant: 34)
                ])
            } else if secondaryAction == nil, secondaryButton.superview != nil {
                secondaryButton.removeFromSuperview()
            }

            guard let secondaryAction else { return }

            secondaryButton.configuration?.background.backgroundColor = secondaryAction.backgroundColor
            secondaryButton.configuration?.image = secondaryAction.image
        }
    }

    private lazy var secondaryButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .capsule
        config.background.backgroundColor = secondaryAction?.backgroundColor
        config.image = secondaryAction?.image
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .small)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.onSecondaryAction?(self)
        }), for: .touchUpInside)
        return button
    }()

    var onSecondaryAction: ((UICollectionViewCell) -> Void)?

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
            button.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            button.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),
            button.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            button.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func configure(for model: Button, shouldShowTitle: Bool) {
        button.updateFor(model, shouldShowTitle: shouldShowTitle)
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        guard secondaryAction != nil else { return }

        if state.isEditing {
            startWobbling()
        } else {
            stopWobbling()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        secondaryAction = nil
    }
}

@available(iOS 15.0, *)
extension UIButton {

    convenience init(button: Button?) {
        var config = UIButton.Configuration.bottomSheetVerticalButton()
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
            case .camera: "camera"
            case .flipCamera: "flip"
            case .cameraEffects: "effects"
            case .audioOutput: "audio output"
            case .fileShare: "fileshare"
            case .screenShare: "screenshare"
            case .chat: "chat"
            case .whiteboard: "board"
            case .addCustom: "new"
            case .custom(let button): button.title ?? "N/A"
        }
    }

    var icon: UIImage {
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
            case .custom(let button): button.icon
        }
        return icon ?? Icons.questionMark
    }

    var backgroundColor: UIColor {
        switch self {
            case .hangUp: .init(rgb: 0xDC2138)
            case .custom(let button): button.background ?? Theme.Color.defaultButtonBackground
            default: Theme.Color.defaultButtonBackground
        }
    }

    var tintColor: UIColor {
        switch self {
            case .hangUp: .white
            case .custom(let button): button.tint ?? Theme.Color.defaultButtonTint
            default: Theme.Color.defaultButtonTint
        }
    }
}
