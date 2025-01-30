// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ButtonCell: UICollectionViewCell {

    private lazy var button: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 18
        config.contentInsets = .init(top: 12, leading: 4, bottom: 12, trailing: 4)
        config.titleAlignment = .center
        config.titleLineBreakMode = .byTruncatingTail
        config.image = UIImage(systemName: "questionmark")
        config.titleTextAttributesTransformer = .init({ _ in
            .init([.font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12)), .foregroundColor : UIColor(rgb: 0x1B1B1B)])
        })
        config.background.customView = ImageTrackingBackgroundView()
        let button = UIButton(configuration: config)
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

    func configure(for model: Button) {
        button.configuration?.title = model.title
        button.configuration?.image = model.icon
        button.configuration?.background.customView?.subviews.first?.backgroundColor = model.backgroundColor
        button.tintColor = model.tintColor
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
