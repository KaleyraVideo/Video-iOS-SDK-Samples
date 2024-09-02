// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

class LoaderView: UIView {

    var isAnimating: Bool = false
    private(set) var image: UIImage
    private var animation: UIViewPropertyAnimator?

    init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)

        setupView()
    }

    private lazy var imageLoader: UIImageView = {
        let imageLoader = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageLoader.image = image
        imageLoader.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            imageLoader.heightAnchor.constraint(equalToConstant: 80),
            imageLoader.widthAnchor.constraint(equalToConstant: 80),
        ])

        return imageLoader
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        addSubview(imageLoader)

        imageLoader.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageLoader.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            imageLoader.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            heightAnchor.constraint(equalTo: imageLoader.heightAnchor)
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
                self.imageLoader.transform = CGAffineTransform(scaleX: -1, y: 1)
            })

        animation?.startAnimation()
    }

    func stopAnimating() {
        isAnimating = false
        animation?.stopAnimation(true)
        animation?.finishAnimation(at: .current)
    }
}

