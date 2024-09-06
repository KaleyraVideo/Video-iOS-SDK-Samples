// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class LoaderView: UIView {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let image: UIImage?
    var isAnimating: Bool = false
    private var animation: UIViewPropertyAnimator?

    init(image: UIImage?) {
        self.image = image
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            heightAnchor.constraint(equalTo: imageView.heightAnchor)
        ])

        sizeToFit()
    }

    func startAnimating(with duration: TimeInterval) {
        isAnimating = true

        animation = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse],
            animations: {
                self.imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            })

        animation?.startAnimation()
    }

    func stopAnimating() {
        isAnimating = false
        animation?.stopAnimation(true)
        animation?.finishAnimation(at: .current)
    }
}

