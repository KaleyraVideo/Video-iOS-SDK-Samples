// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ImageTrackingButtonBackgroundView: UIView {

    private lazy var decorationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 18
        return view
    }()

    override var backgroundColor: UIColor? {
        get {
            decorationView.backgroundColor
        }

        set {
            decorationView.backgroundColor = newValue
        }
    }

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
