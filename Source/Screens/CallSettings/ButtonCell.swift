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
        button.tintColor = UIColor(rgb: 0x1B1B1B)
        return button
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
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
    }

    func configure(for model: Button) {
        button.configuration?.title = model.title
        button.configuration?.image = model.icon
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
