// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

class CircleMaskedImageView: UIImageView {

    private lazy var maskLayer: CAShapeLayer = {
        let mask = CAShapeLayer()
        mask.fillColor = UIColor.white.cgColor
        mask.backgroundColor = UIColor.clear.cgColor
        mask.frame = bounds
        mask.path = makePath()
        return mask
    }()

    override var bounds: CGRect {
        get {
            super.bounds
        }

        set {
            super.bounds = newValue

            maskLayer.frame = newValue

            let newPath = makePath()

            guard let animation = layer.animation(forKey: "bounds.size")?.copy() as? CABasicAnimation else {
                maskLayer.path = newPath
                return
            }

            animation.keyPath = "path"
            animation.fromValue = maskLayer.path
            animation.toValue = newPath
            maskLayer.path = newPath
            maskLayer.add(animation, forKey: "path")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.mask = maskLayer

    }

    private func makePath() -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = CGFloat.minimum(bounds.width, bounds.height) / 2
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
    }

}
